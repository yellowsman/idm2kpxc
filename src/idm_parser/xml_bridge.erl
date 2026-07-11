-module(xml_bridge).
-export([parse_ordered/1]).
-include_lib("xmerl/include/xmerl.hrl").

parse_ordered(XmlBinary) ->
    % io:format("XmlBinary: ~p~n", [XmlBinary]),
    do_parse_odered(XmlBinary, []).

do_parse_odered([], Acc) ->
    lists:flatten(lists:reverse(Acc));
% 改行コードをスキップ
do_parse_odered([$\n | Rest], Acc) ->
    do_parse_odered(Rest, Acc);
do_parse_odered([$\r | Rest], Acc) ->
    do_parse_odered(Rest, Acc);
% スペースをスキップ
do_parse_odered([$\s | Rest], Acc) ->
    do_parse_odered(Rest, Acc);
do_parse_odered([$\t | Rest], Acc) ->
    do_parse_odered(Rest, Acc);
do_parse_odered(XmlBinary, Acc) ->
    % 文字列に日本語が含まれているとエラーになる & バイナリでもcharacter listでも対応できる
    XmlCharList = unicode:characters_to_list(XmlBinary, utf8),

    Options = [
        {space, normalize},
        % この指定をしないとXMLテキストの先頭で定義されているUTF-8の宣言にxmerl_scan:stringが引っ張られる
        {encoding, 'iso-8859-1'}
    ],
    {XmlData, Rest} = xmerl_scan:string(XmlCharList, Options),

    do_parse_odered(Rest, [process_node(XmlData) | Acc]).

process_node(Node) ->
    do_process_node(trim_xml_element(Node)).

is_target_element(#xmlElement{name = Name}) ->
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
    case Child of
        %% 一旦すべての xmlElement を変数「E」として受ける
        E when is_record(E, xmlElement) ->
            is_target_element(E);
        _ ->
            false
    end.

% 処理に使わないXMLの要素を削除
trim_xml_element(#xmlElement{name = 'idmData', content = Children}) ->
    % io:format("Children: ~p~n", [Children]),
    [Child || Child <- Children, filter_element(Child)].

% 空配列なら何もしない
do_process_node([]) ->
    [];
% 引数が「リスト（配列）」の場合はループして単体用関数に回す
do_process_node(NodeList) when is_list(NodeList) ->
    %% リスト内包表記を使って、リストの全要素を1つずつ単体用の関数に放り込む
    [do_process_node(Node) || Node <- NodeList];
% 単体データを処理する
do_process_node(Element) ->
    case Element of
        #xmlElement{name = 'folder'} ->
            do_process_node_folder(Element);
        #xmlElement{name = 'item'} ->
            do_process_node_item(Element);
        _ ->
            ""
    end.

% folder要素の処理
% nameは要素名、attributesは要素が持つ属性の配列、contentは要素が持つ子要素の配列
%  この関数ではパターンマッチによって要素名がfolderの要素のみを引き受け、attributesをAttrsという変数、contentをContentという変数に束縛している
do_process_node_folder(#xmlElement{name = 'folder', attributes = Attrs, content = Content}) ->
    %% Name属性の取得, Name属性を持つ要素の値のリストをリスト内包表記を用いてフィルタしつつ生成
    Name =
        case [A#xmlAttribute.value || A <- Attrs, A#xmlAttribute.name == 'name'] of
            %% Valは要素の値、それをbinary = 文字列に変換する
            [Val] -> unicode:characters_to_binary(Val);
            _ -> <<"unknown">>
        end,
    % 子要素（xmlElement）のみを「元の並び順のまま」再帰的に処理
    Children = [do_process_node(E) || E <- Content, is_record(E, xmlElement)],

    % アトムをGleamのRecordにマッピングさせるための書き方
    {i_d_m_folder, Name, Children}.

% item要素の処理
do_process_node_item(#xmlElement{name = 'item', attributes = Attrs, content = Content}) ->
    % Name属性の取得, Name属性を持つ要素の値のリストをリスト内包表記を用いてフィルタしつつ生成
    Name =
        case [A#xmlAttribute.value || A <- Attrs, A#xmlAttribute.name == 'name'] of
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
    % アトムをGleamのRecordにマッピングさせるための書き方をする
    {i_d_m_item, Name, Account, Password, Item1, Item2, Comment, Url, EmptyText, EmptyText,
        EmptyText, EmptyText, EmptyText, EmptyText}.

fetch_item_field(Node = #xmlElement{name = 'account'}) -> do_fetch_item_field(account, Node);
fetch_item_field(Node = #xmlElement{name = 'password'}) -> do_fetch_item_field(password, Node);
fetch_item_field(Node = #xmlElement{name = 'item1'}) -> do_fetch_item_field(item1, Node);
fetch_item_field(Node = #xmlElement{name = 'item2'}) -> do_fetch_item_field(item2, Node);
fetch_item_field(Node = #xmlElement{name = 'comment'}) -> do_fetch_item_field(comment, Node);
fetch_item_field(Node = #xmlElement{name = 'url'}) -> do_fetch_item_field(url, Node);
%% 上記の以外はnilを返して後で削除する
fetch_item_field(_) -> unuse.

do_fetch_item_field(item1, #xmlElement{attributes = Attrs, content = Content}) ->
    % Name属性の取得, Name属性を持つ要素の値のリストをリスト内包表記を用いてフィルタしつつ生成
    Name =
        case [A#xmlAttribute.value || A <- Attrs, A#xmlAttribute.name == 'name'] of
            %% Valは要素の値、それをbinary = 文字列に変換する
            [Val] -> unicode:characters_to_binary(Val);
            _ -> <<"unknown">>
        end,

    Value =
        case [T || T <- Content, is_record(T, xmlText)] of
            [TextNode] -> unicode:characters_to_binary(TextNode#xmlText.value);
            _ -> <<>>
        end,

    {item1, {Name, Value}};
do_fetch_item_field(item2, #xmlElement{attributes = Attrs, content = Content}) ->
    % Name属性の取得, Name属性を持つ要素の値のリストをリスト内包表記を用いてフィルタしつつ生成
    Name =
        case [A#xmlAttribute.value || A <- Attrs, A#xmlAttribute.name == 'name'] of
            % Valは要素の値、それをbinary = 文字列に変換する
            [Val] -> unicode:characters_to_binary(Val);
            _ -> <<"unknown">>
        end,

    Value =
        case [T || T <- Content, is_record(T, xmlText)] of
            [TextNode] -> unicode:characters_to_binary(TextNode#xmlText.value);
            _ -> <<>>
        end,

    {item2, {Name, Value}};
% paasswordの文字列は再エスケープして元の文字列をそのままコンバート先に使う
do_fetch_item_field(password, #xmlElement{content = Content}) ->
    Value =
        case [T || T <- Content, is_record(T, xmlText)] of
            [TextNode] ->
                escape_special_chars(unicode:characters_to_binary(TextNode#xmlText.value));
            _ ->
                <<>>
        end,

    {password, Value};
do_fetch_item_field(Tag, #xmlElement{content = Content}) ->
    Value =
        case [T || T <- Content, is_record(T, xmlText)] of
            [TextNode] -> unicode:characters_to_binary(TextNode#xmlText.value);
            _ -> <<>>
        end,

    {Tag, Value}.

% パスワードに含まれるデコードされた文字を再エスケープする
escape_special_chars(Binary) when is_binary(Binary) ->
    % 1. 一旦バイナリをリスト(Unicodeコードポイントのリスト)に変換
    List = unicode:characters_to_list(Binary, utf8),

    % 2. 1文字ずつ安全にチェックして置換
    EscapedList = lists:flatmap(
        fun
            ($&) -> "&amp;";
            ($<) -> "&lt;";
            ($>) -> "&gt;";
            ($") -> "&quot;";
            ($') -> "&apos;";
            %% その他の文字はそのまま
            (Char) -> [Char]
        end,
        List
    ),

    % 3. 最後にバイナリに戻す
    unicode:characters_to_binary(EscapedList).
