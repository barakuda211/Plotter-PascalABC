unit AxesModule;

interface
{$reference 'PresentationCore.dll'}

{$apptype windows}

uses System.Windows.Media;

///типы кривой
type
  CurveType = (LineGraph, ScatterGraph, BarGraph, FillBetweenGraph);

///класс кривой
type
  Curve = class
  private
    fname: string;
    ffunc: real-> real;
    ftype: CurveType;
    x_arr: array of real;
    y_arr: array of real;
    facecolor: Color;
    fmarkersize: real := 2.0;
    fspacesize: real := 3.0;
    flinewidth: real := 1.0;
    fbarwidth: real;
    fbarlabels: array of string;
  
  public
    ///вернуть тип кривой
    property GetCurveType: CurveType read ftype;
    ///вернуть/задать название кривой
    property Name: string read fname write fname;
    ///вернуть функцию
    property Func: real-> real read ffunc;
    ///вернуть массив X
    property X: array of real read x_arr;
    ///вернуть массив Y
    property Y: array of real read y_arr;
    ///вернуть цвет кривой
    property GetFacecolor: Color read facecolor;
    ///вернуть/задать размер маркеров
    property MarkerSize: real read fmarkersize write fmarkersize;
    ///вернуть/задать размер промежутков между маркерами
    property SpaceSize: real read fspacesize write fspacesize;
    ///вернуть/задать толщину линии графика
    property LineWidth: real read flinewidth write flinewidth;
    ///вернуть/задать ширину столбцов
    property Width: real read fbarwidth write fbarwidth;
    ///вернуть подписи столбцов
    property GetBarLabels: array of string read fbarlabels;
    
    constructor Create(f: real-> real; ct: CurveType; cl: Color);
    begin
      ftype := ct;
      facecolor := cl;
      ffunc := f;
    end;
    
    constructor Create(x, y: array of real; ct: CurveType; cl: Color);
    begin
      if (x.Length = 0) or (y.Length = 0) then
        raise new Exception('Отстутствие входных параметров X или Y!');
      if (x.Length <> y.Length) then
        raise new Exception('Недостаток введённых данных!');
      
      ftype := ct;
      facecolor := cl;
      x_arr := x;
      y_arr := y;
      ffunc := nil;
      if ct = CurveType.BarGraph then
        if x.Length = 1 then
          fbarwidth := x[0] / 2
        else
          fbarwidth := x[2] - x[1];
    end;
    
    ///возвращает значение функции в точке
    function GetY(x: real): real?;
    ///возвращает true, если задана функцией
    function IsFunctional(): boolean;
    ///возвращает true, если есть название кривой
    function HasName(): boolean;
    
    ///установить цвет кривой
    procedure SetFacecolor(col: Color);
    ///установить подписи столбцов
    procedure SetBarLabels(labels: array of string);
  end;

///Класс области рисования
type
  Axes = class
  
  private
    Xlim: (real, real) := (-10.0, 10.0);
    Ylim: (real, real) := (-10.0, 10.0);
    curvesList: List<Curve> := new List<Curve>();
    
    facecolor: Color := Colors.White;
    
    fisXBounded: boolean := false;
    fisYBounded: boolean := false;
    fGrid: boolean := false;
    fEqProp: boolean := false;
    flegend: boolean := false;
    ftitle: string;
    ftrackmouse: boolean := true;
    
    function checkX(x: array of real): boolean;
  
  public
    constructor Create();
    begin
    end;
    
    ///Вернуть/задать название координатной области
    property Title: string read ftitle write ftitle;
    ///Отображение координатной сетки
    property Grid: boolean read fgrid write fgrid;
    ///пропорциональное отображение по обеим осям
    property EqualProportion: boolean read fEqProp write fEqProp;
    ///вернуть цвет фона
    property GetFacecolor: Color read facecolor;
    ///Ограничен ли X
    property IsXBounded: boolean read fisXBounded;
    ///Ограничен ли Y
    property IsYBounded: boolean read fisYBounded;
    ///Вернуть список кривых
    property GetCurves: List<Curve> read curvesList;
    ///Вернуть границы по оси Х
    property GetXLim: (real, real) read Xlim;
    ///Вернуть границы по оси Y
    property GetYLim: (real, real) read Ylim;
    ///Отображение легенды
    property NeedLegend: boolean read flegend write flegend;
    ///Отображение текущей позиции курсора мыши в координатах графика
    property TrackMouse: boolean read ftrackmouse write ftrackmouse;
    
    ///Построить линейный график по функции
    function Plot(f: real-> real; cl: Color := Colors.Red): Curve;
    ///Построить линейный график по массиву Y
    function Plot(y: array of real; cl: Color := Colors.Red): Curve;
    ///Построить линейный график по массивам X и Y
    function Plot(x, y: array of real; cl: Color := Colors.Red): Curve;
    ///Построить точечный график 
    function Scatter(f: real-> real; cl: Color := Colors.Red): Curve;
    ///Построить точечный график по массиву Y
    function Scatter(y: array of real; cl: Color := Colors.Red): Curve;
    ///Построить точечный график по массивам X и Y
    function Scatter(x, y: array of real; cl: Color := Colors.Red): Curve;
    ///Построить столбчатый график по массиву Y
    function Bar(y: array of real; cl: Color := Colors.Red): Curve;
    ///Построить столбчатый график по массивам X и Y
    function Bar(x, y: array of real; cl: Color := Colors.Red): Curve;
    
    ///Задать границы по оси X
    procedure SetXLim(a, b: real);
    ///Задать границы по оси Y
    procedure SetYLim(a, b: real);
    ///Задать легенду графика
    procedure SetLegend(legend: array of string); 
    ///установить цвет фона
    procedure SetFacecolor(col: Color);
  
  end;

///возвращает цвет по строке
function ColorFromString(cl: string): Color;

implementation

function Axes.Plot(f: real-> real; cl: Color): Curve;
begin
  var c: Curve := new Curve(f, CurveType.LineGraph, cl);
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
  var c := new Curve(x, y, CurveType.LineGraph, cl);
  curvesList.Add(c);
  Result := c;
end;

function Axes.Scatter(f: real-> real; cl: Color): Curve;
begin
  var c: Curve := new Curve(f, CurveType.ScatterGraph, cl);
  curvesList.Add(c);
  fEqProp := true;
  Result := c;
end;

function Axes.Scatter(y: array of real; cl: Color): Curve;
begin
  Result := Scatter((0..y.Length - 1).Select(x -> x * 1.0).ToArray, y, cl);
end;

function Axes.Scatter(x, y: array of real; cl: Color): Curve;
begin
  var c: Curve := new Curve(x, y, CurveType.ScatterGraph, cl);
  curvesList.Add(c);
  Result := c;
end;


function Axes.Bar(y: array of real; cl: Color): Curve;
begin
  Result := Bar((1..y.Length).Select(x -> x * 1.0).ToArray, y, cl);
end;

function Axes.Bar(x, y: array of real; cl: Color): Curve;
begin
  if not checkX(x) then
    raise new Exception('Разное расстояние между элементами X!');
  var c: Curve := new Curve(x, y, CurveType.BarGraph, cl);
  curvesList.Add(c);
  Result := c;
end;


procedure Axes.SetXLim(a, b: real);
begin
  Self.fisxbounded := true;
  Self.Xlim := (a, b);
end;

procedure Axes.SetYLim(a, b: real);
begin
  Self.fisybounded := true;
  Self.Ylim := (a, b);
end;


function Axes.checkX(x: array of real): boolean;
begin
  if x.Length > 1 then
  begin
    var delta := x[1] - x[0];
    for var i := 2 to x.Length - 1 do
      if x[i] - x[i - 1] <> delta then
      begin
        Result := false;
        exit;
      end;
  end;
  Result := true;
end;

procedure Axes.SetLegend(legend: array of string);
begin
  if (legend = nil) or (legend.length <> curvesList.Count) then
    raise new Exception('Ошибочные входные параметры!');
  for var i := 0 to legend.Length - 1 do
    curvesList[i].Name := legend[i];
  flegend := true;
end;

procedure Axes.SetFacecolor(col: Color) := facecolor := col;

///////////////////////////////////////////////////////////////

function Curve.GetY(x: real): real?;
begin
  if func <> nil then
  begin
    Result := func(x);
    exit;
  end;
  
  if (x < x_arr[0]) or (x > x_arr[x_arr.Length - 1]) then
  begin
    Result := nil;
    exit;
  end;
  
  for var i := 1 to x_arr.Length - 1 do
    if (x >= x_arr[i - 1]) and (x < x_arr[i]) then
    begin
      Result := y_arr[i - 1];
      exit;
    end;
  
  Result := y_arr[y_arr.Length - 1];
end;

function ColorFromString(cl: string) := Color(ColorConverter.ConvertFromString(cl));

function Curve.IsFunctional(): boolean := x_arr = nil;

procedure Curve.SetFacecolor(col: Color) := facecolor := col;

procedure Curve.SetBarLabels(labels: array of string);
begin
  if isfunctional or (labels = nil) or 
     (x_arr = nil) or (x_arr.Length <> labels.Length) then
    raise new Exception('Ошибочные входные параметры!');
  fbarlabels := labels;
end;

function Curve.HasName(): boolean := (fname <> nil) and (fname.Length > 0);


initialization

finalization

//раздел финализации

end. 