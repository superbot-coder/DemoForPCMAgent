unit UFrmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, RESTRequest4D, Vcl.Mask,
  Vcl.ExtCtrls, LbCipher, LbClass, System.JSON, Rest.Json, Vcl.Samples.Spin,
  System.NetEncoding, System.IOUtils;

type

  TAccess = class
    FAccessKey: string;
  end;

  TConfig = class
  Private
    FPrivatKey: string;
    FUpdateKey: string;
  public
    property PrivatKey: string read FPrivatKey write FPrivatKey;
    property UpdateKey: string read FUpdateKey write FUpdateKey;
  end;

  TFrmMain = class(TForm)
    BtnUpdate: TButton;
    OpenDialog: TOpenDialog;
    mm: TMemo;
    LblPostFile: TLabel;
    BtnOpenFile: TButton;
    LblEdUpdateKey: TLabeledEdit;
    BtnGet: TButton;
    CmBoxURLPath: TComboBox;
    Label1: TLabel;
    LbRijndael: TLbRijndael;
    lblEdPrivatKey: TLabeledEdit;
    SpEdPort: TSpinEdit;
    LblPort: TLabel;
    LblEdParam: TLabeledEdit;
    LblEdParamValue: TLabeledEdit;
    ChBoxHeaderEnabled: TCheckBox;
    ChBoxPrivatKey: TCheckBox;
    CmBoxHostName: TComboBox;
    LblHostName: TLabel;
    BtnSaveAllKey: TButton;
    procedure BtnUpdateClick(Sender: TObject);
    procedure BtnOpenFileClick(Sender: TObject);
    procedure BtnGetClick(Sender: TObject);
    function CryptStr(StrValue, KeyStr: String): string;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnSaveAllKeyClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FConfig: TConfig;
    function GetAccessKey(const Host: string): string;
  public
    { Public declarations }
    property Config: TConfig read FConfig write FConfig;
  end;

var
  FrmMain: TFrmMain;

  UpdateFile: string;
  AccessStr: string;
  HostListFile: string;
  ConfigFile: string;


function IsHexStr(const StrValue: string): boolean;

implementation

{$R *.dfm}

function IsHexStr(const StrValue: string): boolean;
var
  Hex: set of char;
  s: string;
begin
  s := StrValue.ToLower;
  Hex := ['0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'];
  for var i: Word := 1 to Length(StrValue) do
  begin
    if Not (s[i] in Hex) then
    begin
      Result := false;
      Exit;
    end;
  end;
  Result := true;
end;

procedure TFrmMain.BtnOpenFileClick(Sender: TObject);
begin
  if Not OpenDialog.Execute then Exit;
  LblPostFile.Caption := OpenDialog.FileName;
  UpdateFile := OpenDialog.FileName;
end;

procedure TFrmMain.BtnSaveAllKeyClick(Sender: TObject);
begin
  Config.PrivatKey := lblEdPrivatKey.Text;
  Config.UpdateKey := LblEdUpdateKey.Text;
  TFile.WriteAllText(ConfigFile,
         TJson.ObjectToJsonString(Config, [joIndentCasePreserve]));
end;

procedure TFrmMain.BtnUpdateClick(Sender: TObject);
var
  Resp: IResponse;
  Secret: string;
  Host:   string;
  JAccessKey: TJSONObject;
begin

  if UpdateFile = '' then
  begin
    mm.Lines.Add('Error: Not select update file.');
    Exit;
  end;

  if LblEdUpDateKey.Text = '' then
  begin
    mm.Lines.Add('Error: Empty key encription');
    exit;
  end;

  Host := 'http://' + CmBoxHostName.Text + ':' + SpEdPort.Value.ToString ;
  Resp := TRequest.New.BaseURL(Host + '/access_key').Get;

  JAccessKey := TJSONObject.ParseJSONValue(Resp.Content) as TJSONObject;
  if Not Assigned(JAccessKey) Then
  begin
    mm.Lines.Add('Error:  can not get access_key');
    Exit;
  end;

  try
    Secret := CryptStr(JAccessKey.ToJSON, LblEdUpDateKey.Text);
    Resp := TRequest.New.BaseURL(Host + '/update_agent')
      .Token(Secret)
      .AddFile('file', UpdateFile)
      .Post;
    mm.Lines.Add(Resp.Content);

    if CmBoxHostName.Items.IndexOf(CmBoxHostName.Text) = -1 then
      CmBoxHostName.Items.Add(CmBoxHostName.Text);

  finally
    JAccessKey.Free;
  end;
end;

function TFrmMain.CryptStr(StrValue, KeyStr: String): string;
var
  Key: TKey128;
begin
  if lblEdPrivatKey.Text = '' then Exit;

  Result := '';

  if IsHexStr(KeyStr) then
  begin
    if Length(KeyStr) <> 32 then
    begin
      mm.Lines.Add('Неправильная длина ключа');
      Exit;
    end;
    HexToBin(PChar(KeyStr), Key, 16);
  end
  else
  begin
    if Length(KeyStr) <> 16 then
    begin
       mm.Lines.Add('Неправильная длина ключа');
       exit;
    end;
    move(BytesOf(KeyStr)[0], Key[0], 16);
  end;

  LbRijndael.SetKey(Key);
  Result := LbRijndael.EncryptString(StrValue);
end;

procedure TFrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  CmBoxHostName.Items.SaveToFile(HostListFile);
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  ConfigFile   := TPath.Combine(TPath.GetLibraryPath, 'Config.json');
  HostListFile := TPath.Combine(TPath.GetLibraryPath, 'HostList.lst');

  if Tfile.Exists(HostListFile) then
    CmBoxHostName.Items.LoadFromFile(HostListFile);

  if TFile.Exists(ConfigFile) then
  begin
    FConfig := TJSON.JsonToObject<TConfig>(TFile.ReadAllText(ConfigFile));
    lblEdPrivatKey.Text := Config.PrivatKey;
    LblEdUpdateKey.Text := Config.UpdateKey;
  end
  else
    FConfig := TConfig.Create;

end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
  FConfig.Free;
end;

function TFrmMain.GetAccessKey(const Host: string): string;
begin
  var GetKeyError: Boolean;
  var Resp := TRequest.New.BaseURL(Host + '/access_key').Get;
  var jsonAccessKey := TJSONObject.ParseJSONValue(Resp.Content) as TJSONObject;
  if Assigned(jsonAccessKey) Then
  begin
    try
      if Assigned(jsonAccessKey.FindValue('access_key')) then
        if (Length(jsonAccessKey.Values['access_key'].Value) = 32)
          and (jsonAccessKey.Values['access_key'].Value <> '')
          and IsHexStr(jsonAccessKey.Values['access_key'].Value) then
          Result := jsonAccessKey.ToJSON
        else
        GetKeyError := true;
    finally
      jsonAccessKey.Free;
    end;
  end;

  if GetKeyError then
    mm.Lines.Add('Error:  can not get access_key');

end;

procedure TFrmMain.BtnGetClick(Sender: TObject);
var
  Resp:   IResponse;
  Secret: string;
  Host:   string;
  ParamValue: string;
  jsonAccessKey: string;
begin

  Secret := '';
  Host   := 'http://' + CmBoxHostName.Text + ':' + SpEdPort.Value.ToString ;

  if ChBoxPrivatKey.Checked then
  begin
    jsonAccessKey := GetAccessKey(Host);
    mm.Lines.Add('AccessKey = ' +  jsonAccessKey);
    if lblEdPrivatKey.Text <> '' then
       Secret := CryptStr(jsonAccessKey, lblEdPrivatKey.Text);
    mm.Lines.Add('Secret = ' + Secret);
  end;

  mm.Lines.Add(Host + CmBoxURLPath.Text);

  if ChBoxHeaderEnabled.Checked then
  begin
    ParamValue := TNetEncoding.Base64.Encode(LblEdParamValue.Text);
    mm.Lines.Add('HeaderValue base64 = ' + ParamValue);
    Resp := TRequest.New.BaseURL(Host + CmBoxURLPath.Text)
                  .AddHeader(LblEdParam.Text, ParamValue, [poDoNotEncode, poTransient])
                  .Token(Secret).Get
  end
  else
    Resp := TRequest.New.BaseURL(Host + CmBoxURLPath.Text).Token(Secret).Get;

  if CmBoxHostName.Items.IndexOf(CmBoxHostName.Text) = -1 then
    CmBoxHostName.Items.Add(CmBoxHostName.Text);
  mm.Lines.Add(Resp.Content);

end;

end.
