codeunit 60000 "BC Docker Container Mgt."
{
    Permissions = tabledata "BC Docker Container" = rimd, tabledata "BC URL" = rimd;

    trigger OnRun()
    begin

    end;

    procedure CreateBCDockerContainer(_Name: Text[50]; _Tag: Text[50]; _URL: Text[250])
    var
        BCDockerContainer: Record "BC Docker Container";
        BC_URLs: Record "BC URL";
    begin
        with BCDockerContainer do begin
            Init();
            Name := _Name;
            Tag := _Tag;
            if Insert() then;
        end;
        with BC_URLs do begin
            SetCurrentKey(Name, URL);
            SetRange(URL, _URL);
            SetFilter(Name, '<>%1', '');
            if FindFirst() then exit;
            Name := _Name;
            Modify();
        end;
    end;

    procedure GetBCDockerContainer(_URL: Text[250]): Text
    var
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        Headers: HttpHeaders;
        Client: HttpClient;
        JSText: Text;
        JSObject: JsonObject;
        errMessage: Text;
        errExceptionMessage: Text;

    begin
        RequestMessage.Method := txtRequestMessageMethod;
        RequestMessage.SetRequestUri(_URL);
        RequestMessage.GetHeaders(Headers);

        Client.Send(RequestMessage, ResponseMessage);
        If not ResponseMessage.IsSuccessStatusCode() then begin
            ResponseMessage.Content.ReadAs(JSText);
            JSObject.ReadFrom(JSText);
            errMessage := GetJSToken(JSObject, 'Message').AsValue().AsText();
            errExceptionMessage := GetJSToken(JSObject, 'ExceptionMessage').AsValue().AsText();
            Error('Web service returned error:\\Status code: %1\Description: %2\Message: %3\Exception Message: %4',
                ResponseMessage.HttpStatusCode(), ResponseMessage.ReasonPhrase(), errMessage, errExceptionMessage);
        end;

        ResponseMessage.Content().ReadAs(JSText);
        exit(JSText);
    end;

    procedure GetJSToken(_JSONObject: JsonObject; TokenKey: Text) _JSONToken: JsonToken
    begin
        if not _JSONObject.Get(TokenKey, _JSONToken) then
            Error('Could not find a token with key %1', TokenKey);
    end;

    procedure SelectJSToken(_JSONObject: JsonObject; Path: Text) _JSONToken: JsonToken
    begin
        if not _JSONObject.SelectToken(Path, _JSONToken) then
            Error('Could not find a token with path %1', Path);
    end;

    procedure CreateBCDC(_URL: Text[250]): Boolean
    var
        _jsonObject: JsonObject;
        _jsonArray: JsonArray;
        _jsonToken: JsonToken;
        _jsonText: Text;
        _Name: Text[50];
        _Tag: Text[50];
        _BCDC: Record "BC Docker Container";
        ConfigProgressBarRecord: Codeunit "Conf. Progress Bar";
        RecordCount: Integer;
    begin
        _jsonText := GetBCDockerContainer(_URL);
        _jsonObject.ReadFrom(_jsonText);

        _Name := GetJSToken(_jsonObject, lblName).AsValue().AsText();
        _jsonArray := GetJSToken(_jsonObject, lblTag).AsArray();
        Counter := 0;
        RecordCount := _jsonArray.Count;

        ConfigProgressBarRecord.Init(
          RecordCount, Counter, STRSUBSTNO(ReadingURLMsg, _Name));

        foreach _jsonToken in _jsonArray do begin
            _Tag := _jsonToken.AsValue().AsText();
            CreateBCDockerContainer(_Name, _Tag, _URL);
            Counter += 1;
            ConfigProgressBarRecord.Update(STRSUBSTNO(RecordsXofYMsg, Counter, RecordCount));
        end;

        ConfigProgressBarRecord.Close;
    end;

    var
        Counter: Integer;
        Percentage: Integer;
        TotalCount: Integer;
        dtDiff: Duration;
        dtStart: DateTime;
        Window: Dialog;
        lblName: Label 'name';
        lblTag: Label 'tags';
        txtRequestMessageMethod: Label 'GET';
        RecordsXofYMsg: TextConst ENU = 'Records: %1 of %2', RUS = 'Запись: %1 из %2';
        ReadingURLMsg: TextConst ENU = 'Reading from URL %1', RUS = 'Применяется URL %1';
}