unit uFunctions;

interface

uses
  System.SysUtils, FMX.Dialogs, System.Classes, FMX.TextLayout,
  FMX.ListView.Types, System.Types;

function UTCtoDateBR(dt: string): string;
function GetTextHeight(const D: TListItemText; const Width: single; const Text: string): Integer;

implementation

function UTCtoDateBR(dt: string): string;
begin
    // 2023-05-15T15:23:52.000   -->  15/05/2023 15:23:52
    Result := Copy(dt, 9, 2) + '/' + Copy(dt, 6, 2) + '/' + Copy(dt, 1, 4) + ' ' + Copy(dt, 12, 8);
end;

// Calcula a altura de um item TListItemText
function GetTextHeight(const D: TListItemText; const Width: single; const Text: string): Integer;
var
  Layout: TTextLayout;
begin
  // Create a TTextLayout to measure text dimensions
  Layout := TTextLayoutManager.DefaultTextLayout.Create;
  try
    Layout.BeginUpdate;
    try
      // Initialize layout parameters with those of the drawable
      Layout.Font.Assign(D.Font);
      Layout.VerticalAlign := D.TextVertAlign;
      Layout.HorizontalAlign := D.TextAlign;
      Layout.WordWrap := D.WordWrap;
      Layout.Trimming := D.Trimming;
      Layout.MaxSize := TPointF.Create(Width, TTextLayout.MaxLayoutSize.Y);
      Layout.Text := Text;
    finally
      Layout.EndUpdate;
    end;
    // Get layout height
    Result := Round(Layout.Height);
    // Add one em to the height
    Layout.Text := 'm';
    Result := Result + Round(Layout.Height);
  finally
    Layout.Free;
  end;
end;


end.
