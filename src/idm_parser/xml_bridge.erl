%% src/xml_bridge.erl
-module(xml_bridge).
-export([parse_ordered/1]).
-include_lib("xmerl/include/xmerl.hrl").

parse_ordered(XmlBinary) ->
  % io:format("XmlBinary: ~p~n", [XmlBinary]),
  do_parse_odered(XmlBinary, []).

do_parse_odered([], Acc) -> lists:flatten(lists:reverse(Acc));
do_parse_odered([$\n | Rest], Acc) -> do_parse_odered(Rest, Acc); % 改行コードをスキップ
do_parse_odered([$\r | Rest], Acc) -> do_parse_odered(Rest, Acc);
do_parse_odered([$\s | Rest], Acc) -> do_parse_odered(Rest, Acc); % スペースをスキップ
do_parse_odered([$\t | Rest], Acc) -> do_parse_odered(Rest, Acc);
do_parse_odered(XmlBinary, Acc) ->
    % 文字列に日本語が含まれているとエラーになる & バイナリでもcharacter listでも対応できる
    XmlCharList = unicode:characters_to_list(XmlBinary, utf8),

    % io:format("XmlCharList: ~ts~n", [XmlCharList]),
    % Restは文字列のまま
    Options = [
        % {document, true}, % これは不要だった、XmlDocumentになってしまう
        {space, normalize},
        {encoding, 'iso-8859-1'} % この指定をしないとXMLテキストの先頭で定義されているUTF-8の宣言にxmerl_scan:stringが引っ張られる
    ],
    {XmlData, Rest} = xmerl_scan:string(XmlCharList, Options),
    % {XmlData, Rest} = xmerl_scan:string(XmlCharList),
    % {XmlData, Rest} = xmerl_scan:file("input/endo2-utf8.xml"),

    % io:format("XmlData: ~p~n", [XmlData]),
    % ここに再帰処理を足し込む
    % io:format("Rest: ~p~n", [Rest]),
    % Restが空配列だから再帰処理になっていない
    do_parse_odered(Rest, [process_node(XmlData) | Acc]).

process_node(Node) ->
    % io:format("Node: ~p~n", [Node]),

    do_process_node(trim_xml_element(Node)).
    

is_target_element(#xmlElement{name = Name}) ->
    % io:format("Name: ~p~n", [Name]),
    not lists:member(Name, [
        'familyName',
        'givenName',
        'familyNamePhonetic',
        'givenNamePhonetic',
        'familyNamePhonetic2',
        'givenNamePhonetic2',
        'e-mail1',
        'e-mail2',
        'e-mail3',
        'zip1',
        'prefecture1',
        'address1',
        'zip2',
        'prefecture2',
        'address2',
        'tel1',
        'tel2',
        'handlename1',
        'handlename2',
        'company',
        'defaultAccountName',
        'defaultPasswordName',
        'defaultItem1Name',
        'defaultItem2Name',
        'pasteTypeList'
    ]).

filter_element(Child) ->
    % io:format("Child: ~p~n", [Child]),
    case Child of
        %% 一旦すべての xmlElement を変数「E」として受ける
        E when is_record(E, xmlElement) -> 
            % io:format("is_target_element: ~p~n", [is_target_element(E)]),
            is_target_element(E);
        _ -> false
    end.

% 処理に使わないXMLの要素を削除
trim_xml_element(#xmlElement{name = 'idmData', content = Children}) ->
    % io:format("Children: ~p~n", [Children]),
    [
        Child || Child <- Children, filter_element(Child)
    ].

% 空配列なら何もしない
do_process_node([]) -> [];

% 引数が「リスト（配列）」の場合はループして単体用関数に回す
do_process_node(NodeList) when is_list(NodeList) ->
    %% リスト内包表記を使って、リストの全要素を1つずつ単体用の関数に放り込む
    [do_process_node(Node) || Node <- NodeList];

% 単体データを処理する
do_process_node(Element) ->
    % io:format("Element: ~p~n", [Element]),
    
    
    % === DEBUG ===
    % Type: List
    % Length: 9
    % First 3 elements: [{xmlElement,...},{...}|...]
    % TargetVar = Element, 

    % if
    %     is_tuple(TargetVar) ->
    %         io:format("=== DEBUG ===~nType: Tuple (Record)~nName: ~p~n", [element(1, TargetVar)]);
            
    %     is_list(TargetVar) ->
    %         %% リストの場合、全体を表示すると巨大なので、先頭の3要素だけか、長さを表示する
    %         io:format("=== DEBUG ===~nType: List~nLength: ~p~nFirst 3 elements: ~P~n", [length(TargetVar), TargetVar, 3]);
    %         % io:format("=== DEBUG ===~nType: List~nLength: ~p~nFirst 3 elements: ~p~n", [length(TargetVar), hd(TargetVar)]);
            
    %     is_binary(TargetVar) ->
    %         %% バイナリ（文字列）の場合、先頭の20バイトだけ表示する
    %         <<Prefix:20/binary, _/binary>> = <<TargetVar/binary, "                    ">>,
    %         io:format("=== DEBUG ===~nType: Binary (String)~nPrefix: ~p~n", [Prefix]);
            
    %     true ->
    %         io:format("=== DEBUG ===~nType: Other~nRaw: ~p~n", [TargetVar])
    % end,

    % ここでfolderやitemにパターンマッチしていないらしい
    % それ以外の形式になってるってこと？
    % trimがうまくいってないのかも
    case Element of
        #xmlElement{name = 'folder'} -> 
            io:format("match folder ~n"),
            % io:format("folder element: ~p~n", [Element]),
            do_process_node_folder(Element);
        #xmlElement{name = 'item'} -> 
            io:format("match item ~n"),
            do_process_node_item(Element);
        #xmlElement{name = Name} -> 
            io:format("match ~p~n", [Name]),
            "";
        _ -> "" % ここの分岐には来ていない
    end.

% folder要素の処理
% nameは要素名、attributesは要素が持つ属性の配列、contentは要素が持つ子要素の配列
%  この関数ではパターンマッチによって要素名がfolderの要素のみを引き受け、attributesをAttrsという変数、contentをContentという変数に束縛している
do_process_node_folder(#xmlElement{name = 'folder', attributes = Attrs, content = Content}) ->
    % io:format("call do_process_node_folder ~n"),
    %% Name属性の取得, Name属性を持つ要素の値のリストをリスト内包表記を用いてフィルタしつつ生成
    Name = case [A#xmlAttribute.value || A <- Attrs, A#xmlAttribute.name == 'name'] of
        %% Valは要素の値、それをbinary = 文字列に変換する
        [Val] -> unicode:characters_to_binary(Val);
        _ -> <<"unknown">>
    end,
    % 子要素（xmlElement）のみを「元の並び順のまま」再帰的に処理
    % io:format("-> do_process_node ~n"),
    Children = [do_process_node(E) || E <- Content, is_record(E, xmlElement)],

    % Gleamの User(id, children) にマッピングされるタプル
    % アトムをGleamのRecordにマッピングさせるための書き方をする
    % こう書くとGleam側では'IDMFolder'として扱われる
    {i_d_m_folder, Name, Children}.

% item要素の処理
do_process_node_item(#xmlElement{name = 'item', attributes = Attrs, content = Content}) ->
    % io:format("call do_process_node_item"),
    % Name属性の取得, Name属性を持つ要素の値のリストをリスト内包表記を用いてフィルタしつつ生成
    Name = case [A#xmlAttribute.value || A <- Attrs, A#xmlAttribute.name == 'name'] of
        % Valは要素の値、それをbinary = 文字列に変換する
        [Val] -> unicode:characters_to_binary(Val);
        _ -> <<"unknown">>
    end,

    [
        {account, Account},
        {password, Password},
        {item1, Item1},
        {item2, Item2},
        {comment, Comment},
        {url, Url}
    ] = lists:filter(
        % リスト内包表記によって返却されたリストの中からunuseを取り除く
        fun(I) -> I =/= unuse end,
        [fetch_item_field(I) || I <- Content, is_record(I, xmlElement)]
        ),
    
    % Gleamに空文字として返すには<<>>を使う必要がある
    EmptyText = <<>>,
    % Gleamの Name(String) にマッピングされるタプル
    % アトムをGleamのRecordにマッピングさせるための書き方をする
    % こう書くとGleam側では'IDMItem'として扱われる
    {i_d_m_item, Name, Account, Password, Item1, Item2, Comment, Url, EmptyText, EmptyText, EmptyText, EmptyText, EmptyText, EmptyText}.


% これだと受け取り側が困るでしょ
% 確実Accountにaccountの値が束縛されるようにしないといけない
fetch_item_field(Node = #xmlElement{name = 'account'}) -> do_fetch_item_field(account, Node);
fetch_item_field(Node = #xmlElement{name = 'password'}) -> do_fetch_item_field(password, Node);
fetch_item_field(Node = #xmlElement{name = 'item1'}) -> do_fetch_item_field(item1, Node);
fetch_item_field(Node = #xmlElement{name = 'item2'}) -> do_fetch_item_field(item2, Node);
fetch_item_field(Node = #xmlElement{name = 'comment'}) -> do_fetch_item_field(comment, Node);
fetch_item_field(Node = #xmlElement{name = 'url'}) -> do_fetch_item_field(url, Node);
fetch_item_field(_) -> unuse. %% 上記の以外はnilを返して後で削除する

do_fetch_item_field(item1, #xmlElement{attributes = Attrs, content = Content}) ->
    % Name属性の取得, Name属性を持つ要素の値のリストをリスト内包表記を用いてフィルタしつつ生成
    Name = case [A#xmlAttribute.value || A <- Attrs, A#xmlAttribute.name == 'name'] of
        %% Valは要素の値、それをbinary = 文字列に変換する
        [Val] -> unicode:characters_to_binary(Val);
        _ -> <<"unknown">>
    end,

    Value = case [T || T <- Content, is_record(T, xmlText)] of
        [TextNode] -> unicode:characters_to_binary(TextNode#xmlText.value);
        _ -> <<>>
    end,

    {item1, {Name, Value}};

do_fetch_item_field(item2, #xmlElement{attributes = Attrs, content = Content}) ->
    % Name属性の取得, Name属性を持つ要素の値のリストをリスト内包表記を用いてフィルタしつつ生成
    Name = case [A#xmlAttribute.value || A <- Attrs, A#xmlAttribute.name == 'name'] of
        % Valは要素の値、それをbinary = 文字列に変換する
        [Val] -> unicode:characters_to_binary(Val);
        _ -> <<"unknown">>
    end,

    Value = case [T || T <- Content, is_record(T, xmlText)] of
        [TextNode] -> unicode:characters_to_binary(TextNode#xmlText.value);
        _ -> <<>>
    end,

    {item2, {Name, Value}};

do_fetch_item_field(Tag, #xmlElement{content = Content}) ->
    Value = case [T || T <- Content, is_record(T, xmlText)] of
        [TextNode] -> unicode:characters_to_binary(TextNode#xmlText.value);
        _ -> <<>>
    end,

    {Tag, Value}.
