unit AxesModule;

interface
{$reference 'PresentationCore.dll'}

{$apptype windows}

uses System.Windows.Media;

///типы кривой
type CurveType = (LineGraph, ScatterGraph, BarGraph, FillBetweenGraph);

///класс кривой
type Curve = class
  private
    fname: string;
    fdesc: string;
    ffunc: real -> real;
    ftype: CurveType;
    x_arr: array of real;
    y_arr: array of real;
    facecolor: Color;
    dash_arr: array of real;
    fmarkersize: real := 2.0;
    fspacesize: real := 3.0;
    flinewidth: real := 1.0;
    
  public
    ///вернуть тип кривой
    property GetCurveType: CurveType read ftype;
    ///вернуть/задать название кривой
    property Name: string read fname write fname;
    ///вернуть/задать описание кривой
    property Description: string read fdesc write fdesc;
    ///вернуть функцию
    property Func: real -> real read ffunc;
    ///вернуть массив X
    property X: array of real read x_arr;
    ///вернуть массив Y
    property Y: array of real read y_arr;
    ///вернуть массив длины промежутков
    property Dashes: array of real read dash_arr;
    ///вернуть цвет кривой
    property get_facecolor: Color read facecolor;
    ///вернуть/задать размер маркеров
    property markersize: real read fmarkersize write fmarkersize;
    ///вернуть/задать размер промежутков между маркерами
    property spacesize: real read fspacesize write fspacesize;
    ///вернуть/задать толщину линии графика
    property line_width: real read flinewidth write flinewidth;

    
    constructor Create(f: real->real; ct: CurveType; cl: Color);
    begin
      ftype := ct;
      facecolor := cl;
      ffunc := f;
    end;
    
    constructor Create(x,y: array of real; ct: CurveType; cl: Color);
    begin
      if (x.Length <> y.Length) then
        raise new Exception('Недостаток введённых данных!');
      
      ftype := ct;
      facecolor := cl;
      x_arr := x;
      y_arr := y;
      ffunc := nil;
    end;
    
    ///возвращает значение функции в точке
    function GetY(x: real): real?;
    ///возвращает true, если задана функцией
    function IsFunctional():boolean;
    
    ///установить цвет кривой
    procedure set_facecolor(col: Color);
    ///установить цвет кривой строкой
    procedure set_facecolor(col: string);
  
    ///установить промежутки отрисовки линии графика
    procedure set_dashes(params arr: array of real);
end;

///Класс области рисования
type Axes = class
  
  private
    Title: string := '';
    Xlim: (real, real):= (-10.0, 10.0);
    Ylim: (real, real):= (-10.0, 10.0);
    curvesList: List<Curve> := new List<Curve>();

    facecolor: Color := Colors.White;
    
    isXBounded: boolean := false;
    isYBounded: boolean := false;
    fGrid: boolean := false;
    fEqProp: boolean := false;
    
  public
    constructor Create();
    begin
    end;
   
    ///Отображение координатной сетки
    property Grid: boolean read fgrid write fgrid;
    ///пропорциональное отображение по обеим осям
    property EqualProportion: boolean read fEqProp write fEqProp;
    ///вернуть цвет фона
    property get_facecolor: Color read facecolor;
    ///Ограничен ли X
    property is_x_bounded: boolean read isXBounded;
    ///Ограничен ли Y
    property is_y_bounded: boolean read isYBounded;
    ///Вернуть список кривых
    property Get_Curves: List<Curve> read curvesList;
    ///Вернуть границы по оси Х
    property Get_XLim: (real, real) read Xlim;
    ///Вернуть границы по оси Y
    property Get_YLim: (real, real) read Ylim;
    
    ///Построить линейный график по функции
    function Plot(f: real ->real; cl: Color := Colors.Red): Curve;
    ///Построить линейный график по массиву Y
    function Plot(y: array of real; cl: Color := Colors.Red): Curve;
    ///Построить линейный график по массивам X и Y
    function Plot(x, y: array of real; cl: Color := Colors.Red): Curve;
    ///Построить точечный график 
    function Scatter(f: real ->real; cl: Color := Colors.Red): Curve;
    ///Построить точечный график
    function Scatter(y: array of real; cl: Color := Colors.Red): Curve;
    ///Построить точечный график
    function Scatter(x, y: array of real; cl: Color := Colors.Red): Curve;
    
    ///Задать границы по оси X
    procedure Set_xlim(a, b: real);
    ///Задать границы по оси Y
    procedure Set_ylim(a, b: real);
    ///Задать название графика
    procedure Set_title(title: string);
    ///Вывести легенду графика
    procedure Legend();
    
    ///установить цвет фона
    procedure set_facecolor(col: Color);
    ///установить цвет фона строкой
    procedure set_facecolor(col: string);
    
    
end;

///возвращает цвет по строке
function ColorFromString(cl: string): Color;

implementation

function Axes.Plot(f: real ->real; cl: Color): Curve;
begin
  var c: Curve := new Curve(f,CurveType.LineGraph,cl);
  curvesList.Add(c);
  fEqProp := true;
  Result := c;
end;

function Axes.Plot(y: array of real; cl: Color): Curve;
begin
  Result := Plot((0..y.Length - 1).Select(x -> x * 1.0).ToArray, y, cl);
end;

function Axes.Plot(x, y: array of real; cl: Color): Curve;
begin
  var c := new Curve(x,y,CurveType.LineGraph, cl);
  curvesList.Add(c);
  Result := c;
end;

function Axes.Scatter(f: real ->real; cl: Color): Curve;
begin
  var c: Curve := new Curve(f,CurveType.ScatterGraph,cl);
  curvesList.Add(c);
  fEqProp := true;
  Result := c;
end;

function Axes.Scatter(y: array of real; cl: Color): Curve;
begin
  Result := Scatter((0..y.Length - 1).Select(x -> x * 1.0).ToArray, y,cl);
end;

function Axes.Scatter(x, y: array of real; cl: Color): Curve;
begin
  var c: Curve := new Curve(x,y,CurveType.ScatterGraph,cl);
  curvesList.Add(c);
  Result := c;
end;

//Вывести легенду графика
procedure Axes.Legend();
begin
  
end;


procedure Axes.Set_xlim(a, b: real);
begin
  Self.isxbounded := true;
  Self.Xlim := (a, b);
end;

procedure Axes.Set_ylim(a, b: real);
begin
  Self.isybounded := true;
  Self.Ylim := (a, b);
end;

procedure Axes.Set_title(title: string);
begin
  Self.Title := title;
end;

//установить цвет фона
procedure Axes.set_facecolor(col: Color) := facecolor := col;

//установить цвет фона строкой
procedure Axes.set_facecolor(col: string) := 
  facecolor := Color(ColorConverter.ConvertFromString(col));



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

function ColorFromString(cl: string) := Color(ColorConverter.ConvertFromString(cl));

//возвращает true, если задана функцией
function Curve.IsFunctional(): boolean := x_arr = nil;

//установить цвет фона
procedure Curve.set_facecolor(col: Color) := facecolor := col;

//установить цвет фона строкой
procedure Curve.set_facecolor(col: string) := facecolor := ColorFromString(col);


procedure Curve.set_dashes(params arr: array of real);
begin
  if arr.Length < 2 then
    raise new Exception('Недостаточное кол-во параметров для промежутков.');
  dash_arr := arr;
end;

initialization

finalization

//раздел финализации

end. 