unit FrmDataEdit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  Tfrm_DataEdit = class(TForm)
    memData: TMemo;
    btnOK: TBitBtn;
    btnCancel: TBitBtn;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frm_DataEdit: Tfrm_DataEdit;

implementation

{$R *.dfm}

end.
