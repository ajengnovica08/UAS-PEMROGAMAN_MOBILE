unit frMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.ListBox, FMX.TabControl, FMX.Controls.Presentation, FMX.StdCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, FMX.Edit, FMX.SearchBox, FMX.Ani;

type
  TFMain = class(TForm)
    loMain: TLayout;
    tcMain: TTabControl;
    tiData: TTabItem;
    tiProsesData: TTabItem;
    lbMain: TListBox;
    loTemp: TLayout;
    Label1: TLabel;
    Label2: TLabel;
    lblTempNama: TLabel;
    lblTempAlamat: TLabel;
    QData: TFDQuery;
    SearchBox1: TSearchBox;
    btnTambahData: TCornerButton;
    btnKembali: TCornerButton;
    Label3: TLabel;
    edNama: TEdit;
    Label4: TLabel;
    edAlamat: TEdit;
    btnProses: TCornerButton;
    btnHapus: TCornerButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnTambahDataClick(Sender: TObject);
    procedure btnKembaliClick(Sender: TObject);
    procedure btnProsesClick(Sender: TObject);
    procedure btnHapusClick(Sender: TObject);
    procedure lbMainItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
  private
    Fjenis : String;
    procedure addItem(idx : Integer; nama, alamat : String);   //ctrl + shift + c
    procedure loadItem;
    procedure fnProses(jenis_proses : String);
    procedure fnClear;
  public
    { Public declarations }
  end;

var
  FMain: TFMain;

implementation

{$R *.fmx}

uses uDM;

const
  TAMBAH = 'TAMBAH';
  HAPUS = 'HAPUS';
  UBAH = 'UBAH';

procedure TFMain.addItem(idx: Integer; nama, alamat: String);
var
 lb : TListBoxItem;
 lo : TLayout;
begin
  lblTempNama.Text := nama;
  lblTempAlamat.Text := alamat;

  lb := TListBoxItem.Create(lbMain);
  lb.Width := lbMain.Width;
  lb.Height := loTemp.Height + 8;
  lb.Selectable := False;

  lb.Tag := idx;

  lb.Text := Format('%s %s', [nama, alamat]); //utk search data
  lb.FontColor := $00FFFFFF;
  lb.StyledSettings := [];

  lo := TLayout(loTemp.Clone(lb));
  lo.Width := lb.Width - 16;
  lo.Position.x := 8;
  lo.Position.Y := 0;

  lo.Visible := True;

  lb.AddObject(lo);
  lbMain.AddObject(lb);
end;

procedure TFMain.btnHapusClick(Sender: TObject);
begin
 if FJenis = TAMBAH then
 fnClear
 else
  fnProses(HAPUS);
end;

procedure TFMain.btnKembaliClick(Sender: TObject);
begin
tcMain.Previous();
end;

procedure TFMain.btnProsesClick(Sender: TObject);
begin
fnProses(fJenis);
end;

procedure TFMain.btnTambahDataClick(Sender: TObject);
begin
fJenis := TAMBAH;
tcMain.Next;
end;

procedure TFMain.fnClear;
begin
 edNama.Text := '';
 edAlamat.Text := '';
 FJenis := '';
end;

procedure TFMain.fnProses(jenis_proses: String);
var
  SQLAdd : String;
begin
  try
    if jenis_proses = TAMBAH then begin
       SQLAdd := Format(
        'INSERT INTO tbl_mhs(nama, alamat) VALUES (''%s'', ''%s'')',
        [
        edNama.Text,
        edAlamat.Text
        ]
       );

    end else if jenis_proses = UBAH then begin
      SQLAdd := Format(
      'UPDATE tbl_mhs SET nama = ''%s'', alamat = ''%s'' WHERE id = ''%s''',
      [
      edNama.Text,
      edAlamat.Text,
      QData.FieldByName('id').AsString
      ]
      );

    end else if jenis_proses = HAPUS then begin
      SQLAdd := Format(
      'DELETE FROM tbl_mhs WHERE id = ''%s''',
      [
      QData.FieldByName('id').AsString
      ]
      );

    end else
    Exit;

    DM.Conn.StartTransaction;

    DM.QTemp1.Active := False;
    DM.QTemp1.Close;
    DM.QTemp1.SQL.Clear;
    DM.QTemp1.SQL.Text := SQLAdd;
    DM.QTemp1.ExecSQL;

    loadItem;

    tcMain.First;

    DM.Conn.Commit;

  except
    on E : Exception do begin
      ShowMessage('E.Message');
      DM.Conn.Rollback;
    end;
  end;
end;

procedure TFMain.FormCreate(Sender: TObject);
var i : integer;
begin
 loTemp.Visible := False;
end;

procedure TFMain.FormShow(Sender: TObject);
begin
tcMain.TabIndex := 0;
DM.Conn.Connected := True;
loadItem;
end;

procedure TFMain.lbMainItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
 QData.RecNo := Item.Tag;

 edNama.Text := QData.FieldByName('nama').AsString;
 edAlamat.Text := QData.FieldByName('alamat').AsString;

 Fjenis := UBAH;

 tcMain.Next;
end;

procedure TFMain.loadItem;
var i : Integer;
begin
 try
   lbMain.Items.Clear;
   QData.Active := False;
   QData.SQL.Clear;
   QData.SQL.Text := 'SELECT * FROM tbl_mhs';
   QData.Active := True;
   QData.Open;

   if QData.IsEmpty then begin
    ShowMessage('Tidak Ada Data!');
    Exit;
   end;

   for i := 0 to QData.RecordCount -1 do begin
   addItem(QData.RecNo,
    QData.FieldByName('nama').AsString,
    QData.FieldByName('alamat').AsString
    );
    QData.Next;
   end;

 except
  on E : Exception do begin
     ShowMessage(E.Message);
  end;


 end;
end;

end.
