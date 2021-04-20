unit RendererModule;

interface
{$reference 'PresentationFramework.dll'}
{$reference 'WindowsBase.dll'}
{$reference 'PresentationCore.dll'}

{$apptype windows}

uses System.Windows; 
uses System.Windows.Controls;
uses System.Windows.Media;
uses System.Globalization;
uses FigureModule, AxesModule; 

///шаг отрисовки
var step := 0.1;
///Размеры окна (костыль)
var w, h: real;
///отступы между графиками по осям X и Y
var Borders := (25, 12);

///размеры границ окна
var wp: real := (SystemParameters.BorderWidth + SystemParameters.FixedFrameVerticalBorderWidth) * 2;
var hp: real := SystemParameters.WindowCaptionHeight + (SystemParameters.BorderWidth + SystemParameters.FixedFrameHorizontalBorderHeight) * 2;

type
  VisualContainer = class(FrameworkElement)
  	_drawing: Drawing;
    public
    	constructor(d: Drawing);
  	  begin
  	  	_drawing := d;
  	  end;
    	procedure OnRender(dc: DrawingContext); override;
    	begin
    		dc.DrawDrawing(_drawing);
    	end;
  end;

var app := new Application;
var MainWindow := new Window;
var host := new Canvas;
var mainDrawing := new DrawingGroup;
var mainGroup := new DrawingGroup;

///контейнер для позиционирования графика
type AxesContainer = class
  private
    fax: Axes;
    fposition: (real, real);
    fsize: (real, real);
    forigin: (real, real);
    fborders: (real, real);
    ffield: (real, real);
    fstep: (real, real);
    foriginxy: (real, real);
    fgroup: DrawingGroup := new DrawingGroup;
    fcurvesGroups: List<DrawingGroup> := new List<DrawingGroup>;
    flinewidth: real := 1;  //???
    
  public
    ///вернуть график
    property GetAxes: Axes read fax;
    ///позиция графика
    property Position: (real, real) read fposition;
    ///размер графика
    property Size: (real, real) read fsize;
    ///левый нижний угол координатной области
    property Origin: (real, real) read forigin;
    ///отступы от краёв
    property Borders: (real, real) read fborders;
    ///размеры координатной области
    property FieldSize: (real, real) read ffield;
    ///размер единицы по осям координатной области
    property Step: (real, real) read fstep;
    ///значения X и Y в точке origin
    property OriginXY: (real, real) read foriginxy;
    ///абсолютные координаты точки отсчёта графика
    property AbsoluteOrigin: (real, real) read (fposition.Item1+forigin.Item1, fposition.Item2+forigin.Item2);
    ///Группа рисования
    property Group: DrawingGroup read fgroup;
    ///Возвращает толщину отрисовки коорд. элементов
    property LineWidth: real read flinewidth;
    ///Возвращает группу кривой индекса i
    function CurveGroup(i: integer): DrawingGroup;
    
   
    constructor Create(x, y, size_x, size_y: real; ax: Axes);
    begin
      mainDrawing.Children.Add(fgroup);
      
      foreach var c in ax.Get_Curves do
      begin
        fcurvesGroups.Add(new DrawingGroup);
        mainDrawing.Children.Add(fcurvesGroups[fcurvesGroups.Count-1]);
      end;
      
      fax := ax;
      fposition := (x, y);
      fsize := (size_x, size_y);
      fborders := (size_x*0.05, size_y*0.05);
      forigin := (fborders.Item1, size_y-fborders.Item2);
      
      //отступы от краёв
      var x_border := size_x*0.05;
      var y_border := size_y*0.05;
      //размеры поля
      var field_x := size_x - x_border*2;
      var field_y := size_y - y_border*2;
      ffield := (field_x, field_y);

      //длина единицы
      var step_x := field_x/20;
      var step_y := field_y/10;

      
      //определение границ графика, если есть
      var flag := false;
      var min_x := real.MaxValue;
      var max_x := real.MinValue;
      var min_y := real.MaxValue;
      var max_y := real.MinValue;
      
      for var j:=0 to ax.Get_Curves.Count-1 do
      begin
        var curve := ax.Get_Curves[j];
        
        if curve.IsFunctional then
          continue;
        flag := true;
        if curve.X[0]<min_x then
          min_x := curve.X[0];
        if curve.X[curve.X.Length-1]>max_x then
          max_x := curve.X[curve.X.Length-1];
        
        for var i := 0 to curve.Y.Length-1 do
        begin
          if curve.Y[i]<min_y then
            min_y := curve.Y[i];
          if curve.Y[i]>max_y then
            max_y := curve.Y[i];
        end;
      end;
      
      
      
      //шаг,если заданы значения
      if flag then
      begin
        if not ax.is_x_bounded then
          step_x := field_x/Floor(Abs(max_x-min_x) + 1);
     
        if not ax.is_y_bounded then
          step_y := field_y/Floor(Abs(max_y-min_y) + 1);
      end
      else
      begin
        min_x := ax.Get_XLim.Item1;
        max_x := ax.Get_XLim.Item2;
        min_y := ax.Get_YLim.Item1;
        max_y := ax.Get_YLim.Item2;
      end;
      
      if (ax.is_x_bounded) then
      begin
        step_x := field_x/(ax.Get_XLim.Item2 - ax.Get_XLim.Item1);
        min_x := ax.Get_XLim.Item1;
        max_x := ax.Get_XLim.Item2;
      end;
      
      if (ax.is_y_bounded) then
      begin
        step_y := field_y/(ax.Get_YLim.Item2 - ax.Get_YLim.Item1);
        min_y := ax.Get_YLim.Item1;
        max_y := ax.Get_YLim.Item2;
      end;
      
      if ax.EqualProportion then
        (step_x, step_y) := (min(step_x, step_y),min(step_x, step_y));
      
      foriginxy := (Floor(min_x)*1.0, Floor(min_y)*1.0);
      fstep := (step_x, step_y);
  
    end;
end;

function ColorBrush(c: Color):SolidColorBrush;
function Rect(x,y,w,h: real):System.Windows.Rect;
function Pnt(x,y: real):Point;

///Отобразить окно с графиком
procedure Show(fig: Figure);

///нарисовать график
procedure DrawAxes(x, y, size_x, size_y: real; ax: Axes; fig: Figure);

///нарисовать сетку графиков
procedure DrawMash(rows, cols: integer; x_size, y_size: real);

///Задать размеры окна
procedure WindowSize(width, height: integer);

///Отрисовка кривых одной координатной сетки
procedure DrawCurves(ac: AxesContainer);
 
///Отрисовка координатного интерфейса
procedure DrawCoordinates(ac: AxesContainer; fig: Figure); 

///Отрисовка линейного графика
procedure DrawLineGraph(ac: AxesContainer; ind: integer);

///Расчёт множителя для отображения
function AxesNumberMultiplier(ac: axescontainer):(integer,integer);
 
implementation

procedure Show(fig: Figure);
begin
  
  var dc := mainGroup.Open;
  //FillRectangle(0,0,w, h, fig.get_facecolor);
  mainDrawing.Dispatcher.Invoke(()->
    dc.DrawRectangle(ColorBrush(fig.get_facecolor), nil, Rect(0,0,MainWindow.Width,MainWindow.Height)));  
  dc.Close;
  
  var axes_x_size := ((w - Borders.Item1) / fig.GetAxesMatrix.ColCount) - Borders.Item1;
  var axes_y_size := ((h - Borders.Item2) / fig.GetAxesMatrix.RowCount) - Borders.Item2;
 
  //DrawMash(fig.GetAxesMatrix.RowCount, fig.GetAxesMatrix.ColCount, axes_x_size, axes_y_size);   //отрисовка сетки матрицы
 
  for var k := 0 to fig.GetAxes.Count-1 do
  begin
    var row := Borders.Item2*1.0;
    var col := Borders.Item1*1.0; 
    var x,y,pos: integer;
    for var i := 0 to fig.GetAxesMatrix.RowCount-1 do
    begin
      col := Borders.Item1*1.0; 
      var founded := false;
      for var j := 0 to fig.GetAxesMatrix.ColCount-1 do
      begin
        if fig.GetAxesMatrix[i,j] <> k then
        begin
          col += axes_x_size + Borders.Item1;
          continue;
        end;
        (x, y) := (j, i);
        founded := true;
        break;
      end;
      if founded then
        break;
      row += axes_y_size + Borders.Item2;
    end;
    
    (var count_x, var count_y) := (0,0);
    while (x < fig.GetAxesMatrix.ColCount) and (fig.GetAxesMatrix[y,x] = k) do
    begin
      x += 1;
      count_x += 1;
    end;
    x -= 1;
    while (y < fig.GetAxesMatrix.RowCount) and(fig.GetAxesMatrix[y,x] = k) do
    begin
      y += 1;
      count_y += 1;
    end;
    
    
    
    DrawAxes(col,row,(axes_x_size*count_x)+(Borders.Item1*(count_x-1)),
                      (axes_y_size*count_y)+(Borders.Item2*(count_y-1)),
                        fig.GetAxes[k], fig);
                        
  end;

  app.Run(MainWindow);
end;
  
procedure DrawAxes(x, y, size_x, size_y: real; ax: Axes; fig: Figure);
begin
  var ax_cont := new AxesContainer(x,y,size_x, size_y, ax);

  
  DrawCoordinates(ax_cont, fig);
  
  DrawCurves(ax_cont);
  
end;

//Отрисовка координатного интерфейса
procedure DrawCoordinates(ac: AxesContainer; fig: Figure);
begin
  var (field_x, field_y) := ac.fieldsize;
  var (x_border, y_border) := ac.borders;
  var origin := ac.origin;
  var (x,y) := ac.Position;
  var (size_x, size_y) := ac.Size;
  
  var(x_mult, y_mult) := AxesNumberMultiplier(ac);
  
  var dc_ax := ac.Group.Open;
  mainDrawing.Dispatcher.Invoke(()->
  begin 
    //FillRectangle(x,y,size_x,size_y, fig.get_facecolor);
    
    dc_ax.DrawRectangle(ColorBrush(fig.get_facecolor),nil, Rect(x, y, size_x, size_y));
    
    //Rectangle(x+x_border, y+y_border, size_x-2*x_border, size_y-2*y_border, ac.GetAxes.get_facecolor);
    dc_ax.DrawLine(new Pen(ColorBrush(Colors.Black),ac.LineWidth), Pnt(x+x_border,y+y_border), Pnt(x+size_x-x_border, y+y_border));
    dc_ax.DrawLine(new Pen(ColorBrush(Colors.Black),ac.LineWidth), Pnt(x+size_x-x_border, y+y_border), Pnt(x+size_x-x_border, y+size_y-y_border));
    dc_ax.DrawLine(new Pen(ColorBrush(Colors.Black),ac.LineWidth), Pnt(x+size_x-x_border, y+size_y-y_border), Pnt(x+x_border, y+size_y-y_border));
    dc_ax.DrawLine(new Pen(ColorBrush(Colors.Black),ac.LineWidth), Pnt(x+x_border, y+size_y-y_border), Pnt(x+x_border, y+y_border));
    
    //число на оси координат
    var num := ac.OriginXY.Item1;
    var ftext := new FormattedText(
        num.ToString,
        CultureInfo.GetCultureInfo('en-us'),
        FlowDirection.LeftToRight,
        new Typeface('Verdana'),
        y_border * 0.4,
        Brushes.Black);
    
    //отрисовка чёрточек и сетки
    var temp := origin.Item1;
    while temp <= field_x+x_border do
    begin
      //Line(x+temp, y+origin.Item2, x+temp, y+origin.Item2+y_border*0.3);
      dc_ax.DrawLine(new Pen(ColorBrush(Colors.Black),ac.LineWidth), Pnt(x+temp, y+origin.Item2), Pnt(x+temp, y+origin.Item2+y_border*0.3));
      dc_ax.DrawText(ftext, Pnt(x+temp-ftext.Width/2, y+origin.Item2+y_border*0.35));
      
      //сетка
      if ac.GetAxes.grid then
        dc_ax.DrawLine(new Pen(ColorBrush(Colors.Gray),ac.LineWidth*0.8), Pnt(x+temp, y+origin.Item2), Pnt(x+temp, y+y_border));
      
      num += x_mult;
      ftext := new FormattedText(
        num.ToString,
        CultureInfo.GetCultureInfo('en-us'),
        FlowDirection.LeftToRight,
        new Typeface('Verdana'),
        y_border * 0.4,
        Brushes.Black);
      
      temp += ac.Step.Item1*x_mult;
    end;
    
    num := ac.OriginXY.Item2;
    ftext := new FormattedText(
        num.ToString,
        CultureInfo.GetCultureInfo('en-us'),
        FlowDirection.LeftToRight,
        new Typeface('Verdana'),
        y_border * 0.4,
        Brushes.Black);
    
    temp := origin.Item2;
    while temp >= y_border do
    begin
      //Line(x+origin.Item1, y+temp, x+origin.Item1-x_border*0.3, y+temp);
      dc_ax.DrawLine(new Pen(ColorBrush(Colors.Black),ac.LineWidth), Pnt(x+origin.Item1, y+temp), Pnt(x+origin.Item1-x_border*0.3, y+temp));
      dc_ax.DrawText(ftext, Pnt(x+origin.Item1-x_border*0.4-ftext.Width, y+temp-ftext.Height/2));
      
      //сетка
      if ac.GetAxes.grid then
        dc_ax.DrawLine(new Pen(ColorBrush(Colors.Gray),ac.LineWidth*0.8), Pnt(x+origin.Item1, y+temp), Pnt(x+x_border+field_x, y+temp));
      
      num += y_mult;
      ftext := new FormattedText(
        num.ToString,
        CultureInfo.GetCultureInfo('en-us'),
        FlowDirection.LeftToRight,
        new Typeface('Verdana'),
        y_border * 0.4,
        Brushes.Black);
      
      temp -= ac.Step.Item2*y_mult;
    end;
  end);
  dc_ax.Close;
end;

//Отрисовка кривых одной координатной сетки
procedure DrawCurves(ac: AxesContainer);
begin
  for var i :=0 to ac.GetAxes.Get_Curves.Count-1 do
  begin
    var crv := ac.GetAxes.Get_Curves[i];
    case (crv.GetCurveType) of
      CurveType.LineGraph: DrawLineGraph(ac, i)
    end;
  end;
end;

//Отрисовка линейного графика
procedure DrawLineGraph(ac: AxesContainer; ind: integer);
begin
  
  var crv := ac.GetAxes.Get_Curves[ind];
  var o_x := ac.absoluteOrigin.Item1;
  var o_y := ac.absoluteOrigin.Item2;
  
  var (x_border, y_border) := ac.borders;
  var (xx,yy) := ac.Position;
  var (size_x, size_y) := ac.Size;
  
  if crv.IsFunctional then
  begin
    var func_step := 0.001;
    var ax := ac.GetAxes;
    var (x_min, x_max) := ax.Get_XLim;
    var (y_min, y_max) := ax.Get_YLim;
    var (x_bounded, y_bounded) := (ax.is_x_bounded, ax.is_y_bounded);
    
    var dc_curve := ac.CurveGroup(ind).Open;
    mainDrawing.Dispatcher.Invoke(()->
    begin
      
      var x := x_min;
      var y : real?;
      while (true) do
      begin
        var draw_x := o_x + (x - ac.originxy.Item1)*ac.step.Item1;
        
        if (x_bounded and (x >= x_max))
            or (draw_x > xx+size_x-x_border) then
          break;
        
        y := crv.GetY(x);
        if (not y.HasValue) or 
           (y_bounded and ((y.Value < y_min) or (y.Value > y_max))) then
        begin
          x+= func_step;
          continue;
        end;
        
        var draw_y := o_y - (y.Value - ac.originxy.Item2)*ac.step.Item2;
        
        //костыль
        if (draw_x < xx+x_border)  or
            (draw_y < yy+y_border) or 
            (draw_y >yy+size_y-y_border) then
        begin
          x+= func_step;
          continue;
        end;
        
        dc_curve.DrawEllipse(ColorBrush(crv.get_facecolor),
                              new Pen(ColorBrush(crv.get_facecolor),1.0),
                              Pnt(draw_x, draw_y),1.0,1.0);
        x+= func_step;
      end;
      
    end);
    dc_curve.Close;
    exit;
  end;
  
  var dc_curve := ac.CurveGroup(ind).Open;
  mainDrawing.Dispatcher.Invoke(()->
  begin
    var x1 := (crv.X[0]-ac.originxy.Item1)*ac.step.Item1;
    var y1 := (crv.Y[0]-ac.originxy.Item2)*ac.step.Item2;
    for var i := 1 to crv.X.Length-1 do
    begin
      var x := (crv.X[i]-ac.originxy.Item1)*ac.step.Item1;
      var y := (crv.Y[i]-ac.originxy.Item2)*ac.step.Item2;
      //Line(o_x + x1, o_y - y1, o_x + x, o_y - y, crv.get_facecolor);
      dc_curve.DrawLine(new Pen(ColorBrush(crv.get_facecolor),1.0), Pnt(o_x + x1, o_y - y1), Pnt(o_x + x, o_y - y));
      x1 := x; y1 := y;
    end;
  end);
  dc_curve.Close;
end;

//Возвращает группу кривой индекса i
function AxesContainer.CurveGroup(i: integer): DrawingGroup;
begin
  if (i < 0) or (i >= fcurvesGroups.Count()) then
    raise new Exception('Выход за границы списка групп отрисовки кривых!');
  Result := fcurvesGroups[i];
end;


function AxesNumberMultiplier(ac: axescontainer):(integer, integer);
begin
  var (step_x, step_y) := ac.Step;
  var (field_x, field_y) := ac.FieldSize;
  
  var x_mult1 := 1;
  var x_mult2 := 1;
  
  while field_x/(step_x*x_mult1*x_mult2) > 10 do
  begin
    case x_mult1 of
      1: x_mult1 := 2;
      2: x_mult1 := 5;
      else 
        (x_mult1, x_mult2) := (1, x_mult2*10);
    end;
  end;
  
  var y_mult1 := 1;
  var y_mult2 := 1;
  
  while field_y/(step_y*y_mult1*y_mult2) > 10 do
  begin
    case y_mult1 of
      1: y_mult1 := 2;
      2: y_mult1 := 5;
      else 
        (y_mult1, y_mult2) := (1, y_mult2*10);
    end;
  end;
  
  Result := (x_mult1*x_mult2, y_mult1*y_mult2);
end;


//нарисовать сетку графиков
procedure DrawMash(rows, cols: integer; x_size, y_size: real);
begin
  var x := Borders.Item1*1.0;
  for var i:=0 to cols-1 do
  begin
    //Line(x,0,x,h);
    x += x_size;
    //Line(x,0,x,h);
    x += Borders.Item1;
  end;
  //Line(x,0,x,h);
  
  var y := Borders.Item2*1.0;
  for var i:=0 to rows-1 do
  begin
    //Line(0,y,w,y);
    y += y_size;
    //Line(0,y,w,y);
    y += Borders.Item2;
  end;
  //Line(0,y,w,y);
end;

procedure WindowSize(width, height: integer);
begin
  MainWindow.Width := width + wp;
  MainWindow.Height := height+ hp;
  w := width;
  h := height;
end;

function ColorBrush(c: Color) := new SolidColorBrush(c);
function Rect(x,y,w,h: real) := new System.Windows.Rect(x,y,w,h);
function Pnt(x,y: real) := new Point(x,y);

initialization
  
  MainWindow.Content := host;
  WindowSize(800, 600);
  
  mainDrawing.Children.Add(mainGroup);
  var vis_cont := new VisualContainer(mainDrawing);
  Host.children.Add(vis_cont);
  
  
end.