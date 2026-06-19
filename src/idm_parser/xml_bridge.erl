%% src/xml_bridge.erl
-module(xml_bridge).
-export([parse_ordered/1]).
-include_lib("xmerl/include/xmerl.hrl").

parse_ordered(XmlBinary) ->
    % io:format("XmlBinary: ~p~n", [XmlBinary]),
  do_parse_odered(XmlBinary, []).

do_parse_odered([], Acc) -> lists:reverse(Acc);
do_parse_odered([$\n | Rest], Acc) -> do_parse_odered(Rest, Acc); % 改行コードをスキップ
do_parse_odered([$\r | Rest], Acc) -> do_parse_odered(Rest, Acc);
do_parse_odered([$\s | Rest], Acc) -> do_parse_odered(Rest, Acc); % スペースをスキップ
do_parse_odered([$\t | Rest], Acc) -> do_parse_odered(Rest, Acc);
do_parse_odered(XmlBinary, Acc) ->
    % 文字列に日本語が含まれているとエラーになる & バイナリでもcharacter listでも対応できる
    XmlCharList = unicode:characters_to_list(XmlBinary),
    % io:format("XmlCharList: ~p~n", [XmlCharList]),
    % Restは文字列のまま
    {XmlData, Rest} = xmerl_scan:string(XmlCharList),
    % io:format("XmlData: ~p~n", [XmlData]),
    % ここに再帰処理を足し込む
    % io:format("Rest: ~p~n", [Rest]),
    % Restが空配列だから再帰処理になっていない
    do_parse_odered(Rest, [process_node(XmlData) | Acc]).

process_node(Node) ->
    % io:format("Node: ~p~n", [Node]),

    do_process_node(trim_xml_element(Node)).
    

is_target_element(#xmlElement{name = Name}) ->
    io:format("Name: ~p~n", [Name]),
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


    % <familyName></familyName>
    % <givenName></givenName>
    % <familyNamePhonetic></familyNamePhonetic>
    % <givenNamePhonetic></givenNamePhonetic>
    % <familyNamePhonetic2></familyNamePhonetic2>
    % <givenNamePhonetic2></givenNamePhonetic2>
    % <e-mail1></e-mail1>
    % <e-mail2></e-mail2>
    % <e-mail3></e-mail3>
    % <zip1></zip1>
    % <prefecture1></prefecture1>
    % <address1></address1>
    % <zip2></zip2>
    % <prefecture2></prefecture2>
    % <address2></address2>
    % <tel1></tel1>
    % <tel2></tel2>
    % <handlename1></handlename1>
    % <handlename2></handlename2>
    % <company></company>
    % <defaultAccountName>Account ID</defaultAccountName>
    % <defaultPasswordName>Password</defaultPasswordName>
    % <defaultItem1Name></defaultItem1Name>
    % <defaultItem2Name></defaultItem2Name>
    % <pasteTypeList></pasteTypeList>


filter_element(Child) ->
    % io:format("Child: ~p~n", [Child]),
    case Child of
        %% 一旦すべての xmlElement を変数「E」として受ける
        E when is_record(E, xmlElement) -> 
            io:format("is_target_element: ~p~n", [is_target_element(E)]),
            is_target_element(E);
        _ -> false
    end.

trim_xml_element(#xmlElement{name = 'idmData', content = Children}) ->
    % io:format("Children: ~p~n", [Children]),
    % このChildrenは複数件になるのか？
    [
        Child || Child <- Children, filter_element(Child)
    ].


% これじゃ足りない
% do_process(#xmlElement{content = Content}) ->
    % [process_node(E) || E <- Content, is_record(E, xmlElement)].


do_process_node(TargetNodes) ->
    % io:format("TargetNodes: ~p~n", [TargetNodes]),
    % length(TargetNodes)は1件だけ
    io:format("call do_process_node ~n"),
    % io:format("TargetNodes size: ~p~n", [length(TargetNodes)]),

    % TargetNodesは1件だけしか入っていないので取り出す
    Element = case TargetNodes of
                 [T] -> T;
                 _ -> TargetNodes
                end,

    case Element of
        #xmlElement{name = 'folder'} -> 
            io:format("match folder ~n"),
            % io:format("folder element: ~p~n", [Element]),
            do_process_node_folder(Element);
        #xmlElement{name = 'item'} -> 
            io:format("match item ~n"),
            do_process_node_item(Element);
        _ -> "" % ここの分岐には来ていない
    end.

% folder要素の処理
% nameは要素名、attributesは要素が持つ属性の配列、contentは要素が持つ子要素の配列
%  この関数ではパターンマッチによって要素名がfolderの要素のみを引き受け、attributesをAttrsという変数、contentをContentという変数に束縛している
do_process_node_folder(#xmlElement{name = 'folder', attributes = Attrs, content = Content}) ->
    io:format("call do_process_node_folder ~n"),
    %% Name属性の取得, Name属性を持つ要素の値のリストをリスト内包表記を用いてフィルタしつつ生成
    Name = case [A#xmlAttribute.value || A <- Attrs, A#xmlAttribute.name == 'name'] of
        %% Valは要素の値、それをbinary = 文字列に変換する
        [Val] -> list_to_binary(Val);
        _ -> <<"unknown">>
    end,
    % 子要素（xmlElement）のみを「元の並び順のまま」再帰的に処理
    io:format("-> do_process_node ~n"),
    Children = [do_process_node(E) || E <- Content, is_record(E, xmlElement)],

    % Gleamの User(id, children) にマッピングされるタプル
    % アトムをGleamのRecordにマッピングさせるための書き方をする
    % こう書くとGleam側では'IDMFolder'として扱われる
    {i_d_m_folder, Name, Children}.

% item要素の処理
do_process_node_item(#xmlElement{name = 'item', attributes = Attrs, content = Content}) ->
    io:format("call do_process_node_item"),
    % Name属性の取得, Name属性を持つ要素の値のリストをリスト内包表記を用いてフィルタしつつ生成
    Name = case [A#xmlAttribute.value || A <- Attrs, A#xmlAttribute.name == 'name'] of
        % Valは要素の値、それをbinary = 文字列に変換する
        [Val] -> list_to_binary(Val);
        _ -> <<"unknown">>
    end,

    % TODO Contentの中身を取り出す処理が書けていない
    % リストだろうがタプルだろうが、パターンマッチさせるには左右の辺で位置を揃える必要がある
    % つまり、パターンマッチさせたい順に右辺側を処理する必要がある
    % 問題は、ループの中の各項目がどの値を持っているか分からない点
    % XML側の並びが一定かつループも毎回同じ順番で回ることを前提としてパターンマッチさせる
    [
        {account, Account},
        {password, Password},
        {item1, Item1},
        {item2, Item2},
        {comment, Comment},
        {url, Url}
    ] = lists:filter(
        % リスト内包表記によって返却されたリストの中からnilを取り除く
        fun(I) -> I =/= unuse end,
        [fetch_item_field(I) || I <- Content, is_record(I, xmlElement)]
        ),
    
    % Gleamの Name(String) にマッピングされるタプル
    EmptyText = <<>>,
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
        [Val] -> list_to_binary(Val);
        _ -> <<"unknown">>
    end,

    Value = case [T || T <- Content, is_record(T, xmlText)] of
        [TextNode] -> list_to_binary(TextNode#xmlText.value);
        _ -> <<>>
    end,

    {item1, {Name, Value}};

do_fetch_item_field(item2, #xmlElement{attributes = Attrs, content = Content}) ->
    % Name属性の取得, Name属性を持つ要素の値のリストをリスト内包表記を用いてフィルタしつつ生成
    Name = case [A#xmlAttribute.value || A <- Attrs, A#xmlAttribute.name == 'name'] of
        % Valは要素の値、それをbinary = 文字列に変換する
        [Val] -> list_to_binary(Val);
        _ -> <<"unknown">>
    end,

    Value = case [T || T <- Content, is_record(T, xmlText)] of
        [TextNode] -> list_to_binary(TextNode#xmlText.value);
        _ -> <<>>
    end,

    {item2, {Name, Value}};

do_fetch_item_field(Tag, #xmlElement{content = Content}) ->
    Value = case [T || T <- Content, is_record(T, xmlText)] of
        [TextNode] -> list_to_binary(TextNode#xmlText.value);
        _ -> <<>>
    end,

    {Tag, Value}.






%   IDMItem(
%     title: String,
%     account: String,
%     password: String,
%     item1: #(String, String),
%     item2: #(String, String),
%     comment: String,
%     url: String,
%     serial_number: String,
%     e_mail: String,
%     file: String,
%     issue_date: String,
%     expiration_date: String,
%     paste_type: String,
%   )