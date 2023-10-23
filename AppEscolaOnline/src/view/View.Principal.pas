unit View.Principal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.TabControl,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, System.ImageList, FMX.ImgList, FMX.Calendar, FMX.Layouts,
  FMX.ListBox, Provider.Loading, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, Provider.Functions;

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
    imgNovaMensagem: TImage;
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
    lbiSair: TListBoxItem;
    Label3: TLabel;
    Image4: TImage;
    Line3: TLine;
    rctSombra: TRectangle;
    layMensagem: TLayout;
    rctMensagem: TRectangle;
    lblCPF: TLabel;
    rctAcessar: TRectangle;
    btnEnviar: TSpeedButton;
    mmoMensagem: TMemo;
    btnFecharMensagem: TSpeedButton;
    imgAtualizarRedeSocial: TImage;
    procedure imgHomeClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure calCalendarioDateSelected(Sender: TObject);
    procedure imgNovaMensagemTap(Sender: TObject; const Point: TPointF);
    procedure btnFecharMensagemTap(Sender: TObject; const Point: TPointF);
    procedure imgAtualizarRedeSocialTap(Sender: TObject; const Point: TPointF);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lbiSairTap(Sender: TObject; const Point: TPointF);
    procedure lbiSairClick(Sender: TObject);
    procedure btnEnviarClick(Sender: TObject);
    procedure imgNovaMensagemClick(Sender: TObject);
    procedure ltvSocialUpdateObjects(const Sender: TObject;
      const AItem: TListViewItem);
    procedure imgAtualizarRedeSocialClick(Sender: TObject);
  private
    procedure MudarAba(img: TImage);
    procedure AddMensagem(idMensagem: Integer; nome, data,
mensagem: string; qtdLike, qtdComentario: integer; msg_topo: Boolean = False);
    procedure ListarMensagens;
    procedure AddBoletim(disciplina: string; nota: Double; faltas: integer);
    procedure ListarBoletim;
    procedure ListarCalendario(data: TDate);
    procedure AddCalendario(descricao, hora: string);
    procedure TerminateMensagens(Sender: TObject);
    procedure TerminateBoletim(Sender: TObject);
    procedure TerminateCalendario(Sender: TObject);
    procedure LayoutMensagem(item: TListViewItem);
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

procedure TViewPrincipal.AddMensagem(idMensagem: Integer; nome, data,
mensagem: string; qtdLike, qtdComentario: integer; msg_topo: Boolean = False);
var
  item: TListViewItem;
begin
  if msg_topo then
    item:= ltvSocial.Items.AddItem(0)
  else
    item:= ltvSocial.Items.Add;

  item.Tag:= idMensagem;

  TListItemText(item.Objects.FindDrawable('txtNome')).Text:= nome;
  TListItemText(item.Objects.FindDrawable('txtData')).Text:= Copy(data, 1,5) + ' ' + Copy(data, 12, 5);
  TListItemText(item.Objects.FindDrawable('txtMensagem')).Text:= mensagem;
  TListItemText(item.Objects.FindDrawable('txtLike')).Text:= FormatFloat('#,##0', qtdLike);
  TListItemText(item.Objects.FindDrawable('txtComentario')).Text:= FormatFloat('#,##0', qtdComentario);

  with imgList.Source do
  begin
    TListItemImage(item.Objects.FindDrawable('imgBall')).Bitmap:= Items[0].MultiResBitmap.ItemByScale(1, True, true).Bitmap;
    TListItemImage(item.Objects.FindDrawable('imgLike')).Bitmap:= Items[1].MultiResBitmap.ItemByScale(1, True, true).Bitmap;
    TListItemImage(item.Objects.FindDrawable('imgComentario')).Bitmap:= Items[2].MultiResBitmap.ItemByScale(1, True, true).Bitmap;
  end;

  LayoutMensagem(item);
end;

procedure TViewPrincipal.LayoutMensagem(item: TListViewItem);
var
  txt: TListItemText;
begin
  txt:= TListItemText(item.Objects.FindDrawable('txtMensagem'));
  txt.Width:= ltvSocial.Width - 64;
  txt.Height:= GetTextHeight(txt, txt.Width, txt.text);

  TListItemText(item.Objects.FindDrawable('txtLike')).PlaceOffset.Y:= txt.PlaceOffset.Y + txt.Height;
  TListItemText(item.Objects.FindDrawable('txtComentario')).PlaceOffset.Y:= txt.PlaceOffset.Y + txt.Height;
  TListItemImage(item.Objects.FindDrawable('imgLike')).PlaceOffset.Y:= txt.PlaceOffset.Y + txt.Height;
  TListItemImage(item.Objects.FindDrawable('imgComentario')).PlaceOffset.Y:= txt.PlaceOffset.Y + txt.Height;

  item.Height:= Trunc(txt.PlaceOffset.Y + txt.Height + 25);
end;

procedure TViewPrincipal.btnEnviarClick(Sender: TObject);
var
  t: TThread;
begin
  TLoading.Show(ViewPrincipal, '');
  ltvBoletim.BeginUpdate;

  t:= TThread.CreateAnonymousThread(procedure
  begin
    ProviderConnection.EnviarMensagem(TSession.ID_USUARIO, mmoMensagem.Text);

    TThread.Synchronize(TThread.CurrentThread, procedure
    begin
      with ProviderConnection do
      begin
        AddMensagem(ProviderConnection.fmtMensagens.FieldByName('id_mensagem').AsInteger,
                    TSession.NOME,
                    FormatDateTime('dd/mm/yyyy hh:mm:ss', now),
                    mmoMensagem.Text,
                    0,
                    0,
                    True);

        mmoMensagem.Text:= '';
        layMensagem.Visible:= False;
      end;
    end);
  end);

  t.OnTerminate:= TerminateMensagens;
  t.Start;
end;

procedure TViewPrincipal.btnFecharMensagemTap(Sender: TObject;
  const Point: TPointF);
begin
  layMensagem.Visible:= False;
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
    ProviderConnection.ListarBoletim(TSession.ID_USUARIO, '');

    while not ProviderConnection.fmtBoletim.Eof do
    begin
      TThread.Synchronize(TThread.CurrentThread, procedure
      begin
        with ProviderConnection do
        begin
          AddBoletim(fmtBoletim.FieldByName('disciplina').AsString,
                fmtBoletim.FieldByName('nota').AsFloat,
                fmtBoletim.FieldByName('qtd_falta').AsInteger);
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
          AddMensagem(fmtMensagens.FieldByName('id_mensagem').AsInteger,
                fmtMensagens.FieldByName('nome').AsString,
                UTCtoDateBR(fmtMensagens.FieldByName('dt_geracao').AsString),
                fmtMensagens.FieldByName('mensagem').AsString,
                fmtMensagens.FieldByName('qtd_like').AsInteger,
                fmtMensagens.FieldByName('qtd_comentario').AsInteger);
        end;
      end);
      ProviderConnection.fmtMensagens.Next;
    end;
  end);

  t.OnTerminate:= TerminateMensagens;
  t.Start;
end;

procedure TViewPrincipal.ltvSocialUpdateObjects(const Sender: TObject;
  const AItem: TListViewItem);
begin
  LayoutMensagem(AItem);
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

procedure TViewPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:= TCloseAction.caFree;
  ViewPrincipal:= nil;
end;

procedure TViewPrincipal.FormShow(Sender: TObject);
begin
  layMensagem.Visible:= False;
  ltvSocial.Items.Clear;
  ltvBoletim.Items.Clear;
  ltvCalendario.Items.Clear;

  imgNovaMensagem.Visible:= TSession.TIPO_USUARIO = 'A';

  MudarAba(imgHome);
end;

procedure TViewPrincipal.imgAtualizarRedeSocialClick(Sender: TObject);
begin
  ListarMensagens;
end;

procedure TViewPrincipal.imgAtualizarRedeSocialTap(Sender: TObject;
  const Point: TPointF);
begin
  ListarMensagens;
end;

procedure TViewPrincipal.imgHomeClick(Sender: TObject);
begin
  MudarAba(TImage(Sender));
end;

procedure TViewPrincipal.imgNovaMensagemClick(Sender: TObject);
begin
  mmoMensagem.Text:= '';
  layMensagem.Visible:= True;
end;

procedure TViewPrincipal.imgNovaMensagemTap(Sender: TObject;
  const Point: TPointF);
begin
  mmoMensagem.Text:= '';
  layMensagem.Visible:= True;
end;

procedure TViewPrincipal.lbiSairClick(Sender: TObject);
begin
  TSession.ID_USUARIO:= 0;
  TSession.NOME:= '';

  Close;
end;

procedure TViewPrincipal.lbiSairTap(Sender: TObject; const Point: TPointF);
begin
  TSession.ID_USUARIO:= 0;
  TSession.NOME:= '';

  Close;
end;

end.
