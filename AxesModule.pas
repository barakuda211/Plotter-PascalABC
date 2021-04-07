unit AxesModule;

interface

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
  
  public
    
    property GetCurveType: CurveType read ftype;
    property Name: string read fname write fname;
    property Description: string read fdesc write fdesc;
    property Func: real -> real read ffunc;
    property X: array of real read x_arr;
    property Y: array of real read y_arr;
    
    constructor Create(f: real->real);
    begin
      ffunc := f;
    end;
    
    constructor Create(x,y: array of real);
    begin
      if (x.Length <> y.Length) then
        raise new Exception('Недостаток введённых данных!');
      
      x_arr := x;
      y_arr := y;
      ffunc := nil;
    end;
    
    //возвращает значение функции в точке
    function GetY(x: real): real?;
  
end;

//Класс области рисования
type
  Axes = class
  
  private
    Title: string;
    Xlim, Ylim: (real, real);
    curvesList: List<Curve>;
  
  public
    constructor Create();
    begin
      Xlim := (0.0, 0.0);
      Ylim := (0.0, 0.0);
      curvesList := new List<Curve>();
    end;
    
    //Построить линейный график
    function Plot(y: array of real): Curve;
    //Построить линейный график
    function Plot(x, y: array of real): Curve;
    //Построить точечный график
    function Scatter(y: array of real): Curve;
    //Построить точечный график
    function Scatter(x, y: array of real): Curve;
    
    //Задать границы по оси X
    procedure Set_xlim(a, b: real);
    //Задать границы по оси Y
    procedure Set_ylim(a, b: real);
    //Задать название графика
    procedure Set_title(title: string);
    //Вывести легенду графика
    procedure Legend();
    
    //Вернуть список кривых
    function GetCurves(): List<Curve>;
    //Вернуть границы по оси Х
    function GetXLim(): (real, real);
    //Вернуть границы по оси Y
    function GetYLim(): (real, real);
    
end;

implementation

function Axes.Plot(y: array of real): Curve;
begin
  Result := Plot((0..y.Length - 1).Select(x -> x * 1.0).ToArray, y); 
end;

function Axes.Plot(x, y: array of real): Curve;
begin
  var c: Curve := new Curve(x,y);
  curvesList.Add(c);
  Result := c;
end;

function Axes.Scatter(y: array of real): Curve;
begin
  Result := Scatter((0..y.Length - 1).Select(x -> x * 1.0).ToArray, y);
end;

function Axes.Scatter(x, y: array of real): Curve;
begin
  var c := new Curve(x,y);
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
function Axes.GetCurves(): List<Curve>;
begin
  Result := curvesList;
end;

//Вернуть границы по оси Х
function Axes.GetXLim(): (real, real);
begin
   Result := Xlim;
end;

//Вернуть границы по оси Y
function Axes.GetYLim(): (real, real);
begin
   Result := Ylim;
end;

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

initialization

finalization

//раздел финализации

end. 