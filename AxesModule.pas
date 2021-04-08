unit AxesModule;

interface
{$reference 'PresentationCore.dll'}

{$apptype windows}

uses System.Windows.Media;

//типы кривой
type CurveType = (LineGraph, ScatterGrpah, BarGraph, FillBetweenGraph);

//класс кривой
type
  Curve = class
  private
    fname: string;
    fdesc: string;
    ffunc: real -> real;
    ftype: CurveType;
    x_arr: array of real;
    y_arr: array of real;
    facecolor: Color;
  
  public
    
    property GetCurveType: CurveType read ftype;
    property Name: string read fname write fname;
    property Description: string read fdesc write fdesc;
    property Func: real -> real read ffunc;
    property X: array of real read x_arr;
    property Y: array of real read y_arr;
    
    constructor Create(f: real->real; ct: CurveType; cl: Color);
    begin
      facecolor := cl;
      ffunc := f;
    end;
    
    constructor Create(x,y: array of real; ct: CurveType; cl: Color);
    begin
      if (x.Length <> y.Length) then
        raise new Exception('Недостаток введённых данных!');
      
      facecolor := cl;
      x_arr := x;
      y_arr := y;
      ffunc := nil;
    end;
    
    //возвращает значение функции в точке
    function GetY(x: real): real?;
    //возвращает true, если задана функцией
    function IsFunctional():boolean;
    
    //установить цвет кривой
    procedure set_facecolor(col: Color);
    //установить цвет кривой строкой
    procedure set_facecolor(col: string);
    //вернуть цвет кривой
    function get_facecolor(): Color;
  
end;

//Класс области рисования
type
  Axes = class
  
  private
    Title: string;
    Xlim, Ylim: (real, real);
    curvesList: List<Curve>;
    //цвет координатной зоны
    facecolor: Color;
  
  public
    constructor Create();
    begin
      Xlim := (-10.0, 10.0);
      Ylim := (-5.0, 5.0);
      curvesList := new List<Curve>();
      facecolor := Colors.White;
    end;
    
    //Построить линейный график
    function Plot(y: array of real; cl: Color := Colors.Red): Curve;
    //Построить линейный график
    function Plot(x, y: array of real; cl: Color := Colors.Red): Curve;
    //Построить точечный график
    function Scatter(y: array of real; cl: Color := Colors.Red): Curve;
    //Построить точечный график
    function Scatter(x, y: array of real; cl: Color := Colors.Red): Curve;
    
    //Задать границы по оси X
    procedure Set_xlim(a, b: real);
    //Задать границы по оси Y
    procedure Set_ylim(a, b: real);
    //Задать название графика
    procedure Set_title(title: string);
    //Вывести легенду графика
    procedure Legend();
    
    //Вернуть список кривых
    function Get_Curves(): List<Curve>;
    //Вернуть границы по оси Х
    function Get_XLim(): (real, real);
    //Вернуть границы по оси Y
    function Get_YLim(): (real, real);
    
    //установить цвет фона
    procedure set_facecolor(col: Color);
    //установить цвет фона строкой
    procedure set_facecolor(col: string);
    //вернуть цвет фона
    function get_facecolor(): Color;
    
end;

implementation

function Axes.Plot(y: array of real; cl: Color): Curve;
begin
  Result := Plot((0..y.Length - 1).Select(x -> x * 1.0).ToArray, y, cl); 
end;

function Axes.Plot(x, y: array of real; cl: Color): Curve;
begin
  var c: Curve := new Curve(x,y,CurveType.LineGraph,cl);
  curvesList.Add(c);
  Result := c;
end;

function Axes.Scatter(y: array of real; cl: Color): Curve;
begin
  Result := Scatter((0..y.Length - 1).Select(x -> x * 1.0).ToArray, y, cl);
end;

function Axes.Scatter(x, y: array of real; cl: Color): Curve;
begin
  var c := new Curve(x,y, CurveType.ScatterGrpah, cl);
  curvesList.Add(c);
  Result := c;
end;

//Вывести легенду графика
procedure Axes.Legend();
begin
  
end;


procedure Axes.Set_xlim(a, b: real);
begin
  Self.Xlim := (a, b);
end;

procedure Axes.Set_ylim(a, b: real);
begin
  Self.Ylim := (a, b);
end;

procedure Axes.Set_title(title: string);
begin
  Self.Title := title;
end;

//Вернуть список кривых
function Axes.Get_Curves(): List<Curve>;
begin
  Result := curvesList;
end;

//Вернуть границы по оси Х
function Axes.Get_XLim(): (real, real);
begin
   Result := Xlim;
end;

//Вернуть границы по оси Y
function Axes.Get_YLim(): (real, real);
begin
   Result := Ylim;
end;

//установить цвет фона
procedure Axes.set_facecolor(col: Color) := facecolor := col;

//установить цвет фона строкой
procedure Axes.set_facecolor(col: string) := 
  facecolor := Color(ColorConverter.ConvertFromString(col));

//вернуть цвет фона
function Axes.get_facecolor(): Color := facecolor;

///////////////////////////////////////////////////////////////

//возвращает значение функции в точке
function Curve.GetY(x: real): real?;
begin
  if func <> nil then
  begin
    Result := func(x);
    exit;
  end;
  
  if (x < x_arr[0]) or (x > x_arr[x_arr.Length-1]) then
  begin
    Result := nil;
    exit;
  end;
  
  for var i := 1 to x_arr.Length-1 do
    if (x >= x_arr[i-1]) and (x < x_arr[i]) then
    begin
      Result := y_arr[i-1];
      exit;
    end;
  
  Result := y_arr[y_arr.Length-1];
end;

//возвращает true, если задана функцией
function Curve.IsFunctional(): boolean := x_arr = nil;

//установить цвет фона
procedure Curve.set_facecolor(col: Color) := facecolor := col;

//установить цвет фона строкой
procedure Curve.set_facecolor(col: string) := 
  facecolor := Color(ColorConverter.ConvertFromString(col));

//вернуть цвет фона
function Curve.get_facecolor(): Color := facecolor;

initialization

finalization

//раздел финализации

end. 