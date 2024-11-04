unit UFrmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, RESTRequest4D, Vcl.Mask,
  Vcl.ExtCtrls, LbCipher, LbClass, System.JSON, Rest.Json, Vcl.Samples.Spin,
  System.NetEncoding, System.IOUtils, REST.Types, Vcl.ComCtrls, Vcl.Themes,
  System.ImageList, Vcl.ImgList, Vcl.Imaging.pngimage, Winapi.ShellAPI;


type

  TAccess = class
    FAccessKey: string;
  end;

  TConfig = class
  Private
    FPrivatKey: string;
    FUpdateKey: string;
    FStyle: string;
  public
    property PrivatKey: string read FPrivatKey write FPrivatKey;
    property UpdateKey: string read FUpdateKey write FUpdateKey;
    property Style: string read FStyle write FStyle;
  end;

  TFrmMain = class(TForm)
    OpenDialog: TOpenDialog;
    mm: TMemo;
    LbRijndael: TLbRijndael;
    PageControl: TPageControl;
    TabSheetRequestPCMAgent: TTabSheet;
    TabSheetKeys: TTabSheet;
    TabSheetUpdate: TTabSheet;
    CmBoxParamValue: TComboBox;
    ChBoxPrivatKey: TCheckBox;
    ChBoxHeaderEnabled: TCheckBox;
    LblEdParam: TLabeledEdit;
    BtnGet: TButton;
    CmBoxURLPath: TComboBox;
    Label1: TLabel;
    SpEdPort: TSpinEdit;
    LblPort: TLabel;
    CmBoxHostName: TComboBox;
    LblHostName: TLabel;
    BtnUpdate: TButton;
    BtnOpenFile: TButton;
    BtnSaveAllKey: TButton;
    LblEdUpdateKey: TLabeledEdit;
    lblEdPrivatKey: TLabeledEdit;
    LblEditUpdateFile: TLabeledEdit;
    TabSheetAbout: TTabSheet;
    CmBoxExSelectStyle: TComboBoxEx;
    ImageList: TImageList;
    LblSelecterStyle: TLabel;
    Image1: TImage;
    LblTelegramChannel: TLabel;
    Label2: TLabel;
    LblGitHubSource: TLabel;
    procedure BtnUpdateClick(Sender: TObject);
    procedure BtnOpenFileClick(Sender: TObject);
    procedure BtnGetClick(Sender: TObject);
    function CryptStr(StrValue, KeyStr: String): string;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnSaveAllKeyClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CmBoxExSelectStyleSelect(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure LblMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure LblMouseLeave(Sender: TObject);
    procedure LblClick(Sender: TObject);
  private
    { Private declarations }
    FConfig: TConfig;
    function GetAccessKey(const Host: string): string;

  public
    { Public declarations }
    property Config: TConfig read FConfig write FConfig;
    procedure SaveConfig;
    procedure LoadConfig;
    procedure SaveImitasion;
  end;

var
  FrmMain: TFrmMain;

  UpdateFile: string;
  AccessStr: string;
  CurrentPath: string;
  HostListFile: string;
  ParamValuesFiles: string;
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
  LblEditUpdateFile.Text := OpenDialog.FileName;
  UpdateFile := OpenDialog.FileName;
end;

procedure TFrmMain.BtnSaveAllKeyClick(Sender: TObject);
begin
  Config.PrivatKey := lblEdPrivatKey.Text;
  Config.UpdateKey := LblEdUpdateKey.Text;
  SaveConfig;
  ShowMessage('Saved ok');
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

procedure TFrmMain.CmBoxExSelectStyleSelect(Sender: TObject);
begin
  TStyleManager.SetStyle(CmBoxExSelectStyle.Text);
  Config.Style := CmBoxExSelectStyle.Text;
  SaveConfig;
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

procedure TFrmMain.FormActivate(Sender: TObject);
begin
  TStyleManager.SetStyle(Config.Style);
  if CmBoxExSelectStyle.Items.IndexOf(Config.Style) <> -1 then
  begin
    CmBoxExSelectStyle.Text := Config.Style;
  end;
end;

procedure TFrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  CmBoxHostName.Items.SaveToFile(HostListFile);
  CmBoxParamValue.Items.SaveToFile(ParamValuesFiles);
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  CurrentPath  := TPath.GetLibraryPath;
  ConfigFile   := TPath.Combine(CurrentPath, 'Config.json');
  HostListFile := TPath.Combine(CurrentPath, 'HostList.txt');
  ParamValuesFiles := TPath.Combine(CurrentPath, 'ParamValues.txt');

  if Tfile.Exists(HostListFile) then
    CmBoxHostName.Items.LoadFromFile(HostListFile);

  if Tfile.Exists(ParamValuesFiles) then
    CmBoxParamValue.Items.LoadFromFile(ParamValuesFiles);

  LoadConfig;

  lblEdPrivatKey.Text := Config.PrivatKey;
  LblEdUpdateKey.Text := Config.UpdateKey;

  // Set Styles
  for var StyleName in TStyleManager.StyleNames do
    CmBoxExSelectStyle.ItemsEx.AddItem(StyleName,0 , 0, 0, 0, Nil);

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

procedure TFrmMain.LblMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  (Sender as TLabel).Font.Size := 12;
  (Sender as TLabel).Cursor := crHandPoint;
  (Sender as TLabel).Font.Color := clHighlight;
end;

procedure TFrmMain.LblClick(Sender: TObject);
begin
  ShellExecute(Handle, PChar('Open'),
               PChar((sender as TLabel).Caption),
               Nil, Nil, SW_SHOWNORMAL);
end;

procedure TFrmMain.LblMouseLeave(Sender: TObject);
begin
  (Sender as TLabel).Font.Size := 10;
  (Sender as TLabel).Cursor := crDefault;
  (Sender as TLabel).Font.Color := clWindowText;
end;

procedure TFrmMain.LoadConfig;
begin
  try
    if Not TFile.Exists(ConfigFile) then
    begin
      FConfig := TConfig.Create;
      Exit;
    end;
    FConfig := TJson.JsonToObject<TConfig>(
                 TFile.ReadAllText(ConfigFile, TEncoding.UTF8),
                 [joIndentCasePreserve]);
  except
    on E: Exception do
    begin
      ShowMessage('Error: ' + E.Message + ' metod: TFrmMain.LoadConfig');
    end;
  end;
end;

procedure TFrmMain.SaveConfig;
begin
  var JSOConfig := TJson.ObjectToJsonObject(Config, [joIndentCasePreserve]);
  try
    TFile.WriteAllText(ConfigFile, Tjson.Format(JSOConfig), TEncoding.UTF8);
  finally
    JSOConfig.Free;
  end;
end;

procedure TFrmMain.SaveImitasion;
begin
 // try
    raise Exception.Create('SaveImitasion');
 // Except
    //
 // end;
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
    ParamValue := TNetEncoding.Base64.Encode(CmBoxParamValue.Text);
    mm.Lines.Add('HeaderValue base64 = ' + ParamValue);
    Resp := TRequest.New.BaseURL(Host + CmBoxURLPath.Text)
                  .AddHeader(LblEdParam.Text, ParamValue, [poDoNotEncode, poTransient])
                  .Token(Secret).Get
  end
  else
    Resp := TRequest.New.BaseURL(Host + CmBoxURLPath.Text).Token(Secret).Get;

  mm.Lines.Add(Resp.Content);

  if (CmBoxHostName.Items.IndexOf(CmBoxHostName.Text) = -1)
    and (CmBoxHostName.Text <> '')
  then
    CmBoxHostName.Items.Add(CmBoxHostName.Text);

  if (Resp.StatusCode = 200) and (Resp.ContentType = ctAPPLICATION_JSON) then
  begin
    if (CmBoxParamValue.Items.IndexOf(CmBoxParamValue.Text) = -1)
      and (CmBoxParamValue.Text <> '')
    then
      CmBoxParamValue.Items.Add(CmBoxParamValue.Text);
  end;

end;

end.
