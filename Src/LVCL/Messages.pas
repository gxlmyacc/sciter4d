unit Messages;

interface

const
  WM_NULL              = $0000;
  WM_CREATE            = $0001;
  WM_DESTROY           = $0002;
  WM_CLOSE             = $0010;
  WM_QUERYENDSESSION   = $0011;
  WM_QUIT              = $0012;
  WM_PAINT             = $000F;
  WM_SHOWWINDOW        = $0018;
  WM_CANCELMODE        = $001F;
  WM_SETCURSOR         = $0020;
  WM_MOUSEACTIVATE     = $0021;
  WM_GETMINMAXINFO     = $0024;
  WM_WINDOWPOSCHANGING = $0046;
  WM_WINDOWPOSCHANGED  = $0047;
  WM_NCACTIVATE        = $0086;
  WM_GETDLGCODE        = $0087;
  WM_NCLBUTTONDOWN     = $00A1;
  WM_KEYFIRST          = $0100;
  WM_KEYDOWN           = $0100;
  WM_KEYUP             = $0101;
  WM_CHAR              = $0102;
  WM_SYSKEYDOWN        = $0104;
  WM_SYSKEYUP          = $0105;
  WM_SYSCHAR           = $0106;
  WM_SYSDEADCHAR       = $0107;
  WM_KEYLAST           = $0108;
  WM_SYSCOMMAND        = $0112;


implementation

end.