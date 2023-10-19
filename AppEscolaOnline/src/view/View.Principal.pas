unit View.Principal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.TabControl,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, System.ImageList, FMX.ImgList, FMX.Calendar, FMX.Layouts,
  FMX.ListBox, Provider.Loading;

type
  TViewPrincipal = class(TForm)
    rctAbas: TRectangle;
    imgHome: TImage;
    imgBoletim: TImage;
    imgCalendario: TImage;
    imgConfiguracoes: TImage;
    tbcAbas: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    TabItem3: TTabItem;
    TabItem4: TTabItem;
    rctRedeSocial: TRectangle;
    imgRedeSocial: TImage;
    rctBoletimEscolar: TRectangle;
    imgBoletimEscolar: TImage;
    rctCalendarioEscolar: TRectangle;
    imgCalendarioEscolar: TImage;
    Rectangle1: TRectangle;
    Image1: TImage;
    ltvSocial: TListView;
    imgList: TImageList;
    img1: TImage;
    ltvBoletim: TListView;
    calCalendario: TCalendar;
    rctDia: TRectangle;
    lblDia: TLabel;
    ltvCalendario: TListView;
    ListBox1: TListBox;
    ListBoxItem1: TListBoxItem;
    Label1: TLabel;
    Image2: TImage;
    Line1: TLine;
    ListBoxItem2: TListBoxItem;
    Label2: TLabel;
    Image3: TImage;
    Line2: TLine;
    ListBoxItem3: TListBoxItem;
    Label3: TLabel;
    Image4: TImage;
    Line3: TLine;
    procedure imgHomeClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure calCalendarioDateSelected(Sender: TObject);
  private
    procedure MudarAba(img: TImage);
    procedure AddMensagem(idMensagem: Integer; nome, data, mensagem: string; qtdLike, qtdComentario: integer);
    procedure ListarMensagens;
    procedure AddBoletim(disciplina: string; nota: Double; faltas: integer);
    procedure ListarBoletim;
    procedure ListarCalendario(data: TDate);
    procedure AddCalendario(descricao, hora: string);
    procedure TerminateMensagens(Sender: TObject);
    procedure TerminateBoletim(Sender: TObject);
    procedure TerminateCalendario(Sender: TObject);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ViewPrincipal: TViewPrincipal;

implementation

uses
  Provider.Connection, Provider.Session;

{$R *.fmx}

{ TViewPrincipal }

procedure TViewPrincipal.calCalendarioDateSelected(Sender: TObject);
begin
  ListarCalendario(calCalendario.Date);
end;

procedure TViewPrincipal.ListarCalendario(data: TDate);
var
  t: TThread;
begin
  TLoading.Show(ViewPrincipal, '');
  ltvCalendario.BeginUpdate;
  ltvCalendario.Items.Clear;
  lblDia.Text:= 'Atividades de '+ FormatDateTime('dd/mm', data);

  t:= TThread.CreateAnonymousThread(procedure
  begin
    //Sincronizar alterações visuais para o usuário na TThread principal;
    ProviderConnection.ListarCalendario(TSession.ID_USUARIO, data);

    while not ProviderConnection.fmtCalendario.Eof do
    begin
      TThread.Synchronize(TThread.CurrentThread, procedure
      begin
        with ProviderConnection do
        begin
          AddCalendario(fmtCalendario.FieldByName('descricao').AsString,
                fmtCalendario.FieldByName('hora').AsString);
        end;
      end);
      ProviderConnection.fmtCalendario.Next;
    end;
  end);

  t.OnTerminate:= TerminateCalendario;
  t.Start;
end;

procedure TViewPrincipal.AddCalendario(descricao, hora: string);
var
  item: TListViewItem;
begin
  item:= ltvCalendario.Items.Add;

  TListItemText(item.Objects.FindDrawable('txtDescricao')).Text:= descricao;
  TListItemText(item.Objects.FindDrawable('txtHora')).Text:= hora;
end;

procedure TViewPrincipal.AddMensagem(idMensagem: Integer; nome, data, mensagem: string; qtdLike, qtdComentario: integer);
var
  item: TListViewItem;
begin
  item:= ltvSocial.Items.Add;

  item.Tag:= idMensagem;

  TListItemText(item.Objects.FindDrawable('txtNome')).Text:= nome;
  TListItemText(item.Objects.FindDrawable('txtData')).Text:= data;
  TListItemText(item.Objects.FindDrawable('txtMensagem')).Text:= mensagem;
  TListItemText(item.Objects.FindDrawable('txtLike')).Text:= FormatFloat('#,##', qtdLike);
  TListItemText(item.Objects.FindDrawable('txtComentario')).Text:= FormatFloat('#,##', qtdComentario);

  with imgList.Source do
  begin
    TListItemImage(item.Objects.FindDrawable('imgBall')).Bitmap:= Items[0].MultiResBitmap.ItemByScale(1, True, true).Bitmap;
    TListItemImage(item.Objects.FindDrawable('imgLike')).Bitmap:= Items[1].MultiResBitmap.ItemByScale(1, True, true).Bitmap;
    TListItemImage(item.Objects.FindDrawable('imgComentario')).Bitmap:= Items[2].MultiResBitmap.ItemByScale(1, True, true).Bitmap;
  end;
end;

procedure TViewPrincipal.AddBoletim(disciplina: string; nota: Double; faltas: integer);
var
  item: TListViewItem;
begin
  item:= ltvBoletim.Items.Add;

  TListItemText(item.Objects.FindDrawable('txtDisciplina')).Text:= disciplina;
  TListItemText(item.Objects.FindDrawable('txtTituloNota')).Text:= 'Nota';
  TListItemText(item.Objects.FindDrawable('txtValorNota')).Text:= FormatFloat('0.0', nota);
  TListItemText(item.Objects.FindDrawable('txtTituloFalta')).Text:= 'Faltas';
  TListItemText(item.Objects.FindDrawable('txtValorFalta')).Text:= faltas.ToString;
end;

procedure TViewPrincipal.ListarBoletim;
var
  t: TThread;
begin
  TLoading.Show(ViewPrincipal, '');
  ltvBoletim.BeginUpdate;
  ltvBoletim.Items.Clear;

  t:= TThread.CreateAnonymousThread(procedure
  begin
    //Sincronizar alterações visuais para o usuário na TThread principal;
    ProviderConnection.ListarBoletim(TSession.ID_USUARIO);

    while not ProviderConnection.fmtBoletim.Eof do
    begin
      TThread.Synchronize(TThread.CurrentThread, procedure
      begin
        with ProviderConnection do
        begin
          AddBoletim(fmtBoletim.FieldByName('disciplina').AsString,
                fmtBoletim.FieldByName('nota').AsFloat,
                fmtBoletim.FieldByName('faltas').AsInteger);
        end;
      end);
      ProviderConnection.fmtBoletim.Next;
    end;
  end);

  t.OnTerminate:= TerminateBoletim;
  t.Start;
end;

procedure TViewPrincipal.ListarMensagens;
var
  t: TThread;
begin
  TLoading.Show(ViewPrincipal, '');
  ltvSocial.BeginUpdate;
  ltvSocial.Items.Clear;

  t:= TThread.CreateAnonymousThread(procedure
  begin
    //Sincronizar alterações visuais para o usuário na TThread principal;
    ProviderConnection.ListarMensagens(TSession.ID_USUARIO);

    while not ProviderConnection.fmtMensagens.Eof do
    begin
      TThread.Synchronize(TThread.CurrentThread, procedure
      begin
        with ProviderConnection do
        begin
          AddMensagem(fmtMensagens.FieldByName('id').AsInteger,
                fmtMensagens.FieldByName('nome').AsString,
                fmtMensagens.FieldByName('dt').AsString,
                fmtMensagens.FieldByName('msg').AsString,
                fmtMensagens.FieldByName('like').AsInteger,
                fmtMensagens.FieldByName('comentario').AsInteger);
        end;
      end);
      ProviderConnection.fmtMensagens.Next;
    end;
  end);

  t.OnTerminate:= TerminateMensagens;
  t.Start;
end;

procedure TViewPrincipal.TerminateMensagens(Sender: TObject);
begin
  TLoading.Hide;
  ltvSocial.EndUpdate;

  if Sender is TThread then
    if Assigned(TThread(Sender).FatalException) then
      ShowMessage(Exception(TThread(Sender).FatalException).Message);
end;

procedure TViewPrincipal.TerminateBoletim(Sender: TObject);
begin
  TLoading.Hide;
  ltvBoletim.EndUpdate;

  if Sender is TThread then
    if Assigned(TThread(Sender).FatalException) then
      ShowMessage(Exception(TThread(Sender).FatalException).Message);
end;

procedure TViewPrincipal.TerminateCalendario(Sender: TObject);
begin
  TLoading.Hide;
  ltvCalendario.EndUpdate;

  if Sender is TThread then
    if Assigned(TThread(Sender).FatalException) then
      ShowMessage(Exception(TThread(Sender).FatalException).Message);
end;

procedure TViewPrincipal.MudarAba(img: TImage);
begin
  imgHome.Opacity:= 0.5;
  imgBoletim.Opacity:= 0.5;
  imgCalendario.Opacity:= 0.5;
  imgConfiguracoes.Opacity:= 0.5;

  img.Opacity:= 1;
  tbcAbas.GotoVisibleTab(img.Tag);

  if (img.tag = 0) and (ltvSocial.items.Count = 0) then
    ListarMensagens
  else if (img.Tag = 1) and (ltvBoletim.Items.Count = 0) then
    ListarBoletim
  else if (img.Tag = 2) and (ltvCalendario.Items.Count = 0) then
    ListarCalendario(calCalendario.Date);
end;

procedure TViewPrincipal.FormShow(Sender: TObject);
begin
  MudarAba(imgHome);
end;

procedure TViewPrincipal.imgHomeClick(Sender: TObject);
begin
  MudarAba(TImage(Sender));
end;

end.
