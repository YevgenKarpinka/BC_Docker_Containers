codeunit 60000 "BC Docker Container Mgt."
{
    trigger OnRun()
    begin

    end;

    procedure CreateBCDockerContainer(_Name: Text[50]; _Tag: Text[50])
    var
        BCDockerContainer: Record "BC Docker Container";
    begin
        with BCDockerContainer do begin
            SetCurrentKey(Name, Tag);
            SetRange(Name, _Name);
            SetRange(Tag, _Tag);
            if IsEmpty() then begin
                Init();
                Name := _Name;
                Tag := _Tag;
                Insert();
            end;
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
        txtRequestMessageMethod: Label 'GET';
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

    procedure CreateBCDC(_BCName: Text[50]; _URL: Text[250]): Boolean
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

        _BCDC.SetRange(Name, _BCName);
        _BCDC.DeleteAll();

        _Name := GetJSToken(_jsonObject, lblName).AsValue().AsText();
        _jsonArray := GetJSToken(_jsonObject, lblTag).AsArray();
        Counter := 0;
        RecordCount := _jsonArray.Count;

        ConfigProgressBarRecord.Init(
          RecordCount, Counter, STRSUBSTNO(ApplyingURLMsg, _Name));

        foreach _jsonToken in _jsonArray do begin
            _Tag := _jsonToken.AsValue().AsText();
            CreateBCDockerContainer(_Name, _Tag);
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
        RecordsXofYMsg: TextConst ENU = 'Records: %1 of %2', RUS = 'Запись: %1 из %2';
        ApplyingURLMsg: TextConst ENU = 'Rading from URL %1', RUS = 'Применяется URL %1';
}