unit RendererModule;

interface

//{$reference 'PresentationFramework.dll'}
//{$reference 'WindowsBase.dll'}
//{$reference 'System.Windows.Forms.dll'}
//{$reference 'PresentationCore.dll'}
//{$apptype windows}
{
uses System.Windows; 
uses System.Windows.Controls;
uses System.Windows.Media;
uses System.Globalization;
}
uses GraphWPF1, FigureModule, AxesModule;

///шаг отрисовки
var
  step := 0.1;
///Размеры окна (костыль)
var
  w, h: real;
///отступы между графиками по осям X и Y
var
  Borders := (10, 8);
///отображаемый экземпляр Figure
var
  fig: Figure;

{
///размеры границ окна
var wp: real := (SystemParameters.BorderWidth + SystemParameters.FixedFrameVerticalBorderWidth) * 2;
var hp: real := SystemParameters.WindowCaptionHeight + (SystemParameters.BorderWidth + SystemParameters.FixedFrameHorizontalBorderHeight) * 2;

type VisualContainer = class(FrameworkElement)
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
}
///контейнер для позиционирования графика
type
  AxesContainer = class
  private
    fax: Axes;
    fposition: (real, real);
    fsize: (real, real);
    forigin: (real, real);
    fborders: (real, real);
    ffield: (real, real);
    fstep: (real, real);
    foriginxy: (real, real);
    flinewidth: real := 1;  
    ffuncstep : real;
    fnumssize: real;
    fynums: array of real;
    fxnums: array of real;
    faxesmultipliers: (real, real);
    ffoptnums: FontOptions;
    fcountaxesnums: (integer, integer) := (10,10);
    fptsize: real;
    fptsizexy: real;
    fminmaxx: (real, real);
    fminmaxy: (real, real);
    
    ///Расчёт размера шрифта на осях
    procedure SetNumSize;
    ///Расчёт чисел на осях
    procedure SetNums;
    ///Расчёт расстояний между точками точечного графика
    procedure SetSpaces;
    ///Заполнение полей
    procedure Init(x, y, size_x, size_y: real; ax: Axes);
    ///Расчёт множителя для отображения
    procedure AxesNumberMultiplier;
  
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
    property AbsoluteOrigin: (real, real) read (fposition.Item1 + forigin.Item1, fposition.Item2 + forigin.Item2);
    ///Возвращает толщину отрисовки коорд. элементов
    property LineWidth: real read flinewidth;
    ///Возвращает размер чисел на осях
    property GetNumsSize: real read fnumssize;
    ///Возвращает массив чисел оси Y
    property YNums: array of real read fynums;
    ///Возвращает массив чисел оси X
    property XNums: array of real read fxnums;
    ///Возвращает множитель чисел на осях
    property AxesMultipliers: (real, real) read faxesmultipliers;
    ///Возвращает шрифт для текста
    property GetFontOptions: FontOptions read ffoptnums;
    ///Возвращает шаг для отрисовки функции
    property GetFuncStep: real read ffuncstep;
    ///Возвращает размер единичного штриха
    property GetPtSize: real read fptsize;
    ///Возвращает размер единичного штриха относительно X и Y
    property GetPtSizeXY: real read fptsizexy;
    
    constructor Create(x, y, size_x, size_y: real; ax: Axes);
    begin
      {
      mainDrawing.Children.Add(fgroup);
      
      foreach var c in ax.Get_Curves do
      begin
        fcurvesGroups.Add(new DrawingGroup);
        mainDrawing.Children.Add(fcurvesGroups[fcurvesGroups.Count-1]);
      end;
      }
      Init(x, y, size_x, size_y, ax);
      AxesNumberMultiplier;
      SetNums;
      SetNumSize;
      SetSpaces;
    end;
    
    
    
    ///Возвращает размер маркеров по индексу кривой
    function GetMarkerSize(ind: integer): real;
    
    ///Возвращает значение промежутков точечного графика по индексу кривой
    function GetScatterSpace(ind: integer): real;
    
    ///Возвращает значение функции в указанной глобальной позиции
    function GetXYByMouse(x, y: real): (real?, real?);
  
  end;

///список отображаемых координатных сеток
var
  AxContList := new List<AxesContainer>;

///Отобразить окно с графиком
procedure Show(f: Figure);

///нарисовать график
procedure DrawAxes(x, y, size_x, size_y: real; ax: Axes; fig: Figure);

///Задать размеры окна
procedure WindowSize(width, height: integer);

///Отрисовка кривых одной координатной сетки
procedure DrawCurves(ac: AxesContainer);

///Отрисовка координатного интерфейса
procedure DrawCoordinates(ac: AxesContainer; fig: Figure);

///Отрисовка линейного графика
procedure DrawLineGraph(ac: AxesContainer; ind: integer);

///Отрисовка линейного графика
procedure DrawScatterGraph(ac: AxesContainer; ind: integer);

implementation

procedure Show(f: Figure);
begin
  fig := f;
  w := GraphWindow.Width;
  h := GraphWindow.Height;
  //var dc := mainGroup.Open;
  
  //FillRectangle(0,0,w, h, fig.get_facecolor);
  
  PlotterInvokeVisual(()->
  begin
    var dc := PlotterGetDC;
    RectangleDC(dc, 0, 0, w, h, fig.get_facecolor);
    dc.Close;
  end);
  
  
  var axes_x_size := ((w - Borders.Item1) / fig.GetAxesMatrix.ColCount) - Borders.Item1;
  var axes_y_size := ((h - Borders.Item2) / fig.GetAxesMatrix.RowCount) - Borders.Item2;
  
  for var k := 0 to fig.GetAxes.Count - 1 do
  begin
    var row := Borders.Item2 * 1.0;
    var col := Borders.Item1 * 1.0; 
    var x, y, pos: integer;
    for var i := 0 to fig.GetAxesMatrix.RowCount - 1 do
    begin
      col := Borders.Item1 * 1.0; 
      var founded := false;
      for var j := 0 to fig.GetAxesMatrix.ColCount - 1 do
      begin
        if fig.GetAxesMatrix[i, j] <> k then
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
    
    (var count_x, var count_y) := (0, 0);
    while (x < fig.GetAxesMatrix.ColCount) and (fig.GetAxesMatrix[y, x] = k) do
    begin
      x += 1;
      count_x += 1;
    end;
    x -= 1;
    while (y < fig.GetAxesMatrix.RowCount) and (fig.GetAxesMatrix[y, x] = k) do
    begin
      y += 1;
      count_y += 1;
    end;
    
    
    
    DrawAxes(col, row, (axes_x_size * count_x) + (Borders.Item1 * (count_x - 1)),
                      (axes_y_size * count_y) + (Borders.Item2 * (count_y - 1)),
                        fig.GetAxes[k], fig);
    
  end;
  
  {
  MainWindow.MouseMove += (o,e)->
  begin
  var p := e.GetPosition(o as System.Windows.IInputElement);
  var (x, y) := (-1.0, -1.0);
  
  foreach var cont in AxContList do
  begin
  var pos := cont.GetXYByMouse(p.X, p.Y);
  if pos.Item1.HasValue then
  begin
  (x,y) := (pos.Item1.Value, pos.Item2.Value);
  break;
  end;
  end;
  
  MainWindow.Title := '('+x+'; '+y+')';
  
  end;
  }
  //app.Run(MainWindow);
end;

procedure DrawAxes(x, y, size_x, size_y: real; ax: Axes; fig: Figure);
begin
  var ax_cont := new AxesContainer(x, y, size_x, size_y, ax);
  
  AxContList.Add(ax_cont);
  
  DrawCoordinates(ax_cont, fig);
  
  DrawCurves(ax_cont);
  
end;

//Отрисовка координатного интерфейса
procedure DrawCoordinates(ac: AxesContainer; fig: Figure);
begin
  var (field_x, field_y) := ac.fieldsize;
  var (x_border, y_border) := ac.borders;
  var origin := ac.origin;
  var (x, y) := ac.Position;
  var (size_x, size_y) := ac.Size;
  var(x_mult, y_mult) := ac.AxesMultipliers;
  
  Font := ac.GetFontOptions;
  
  PlotterInvokeVisual(()->
  begin
    
    var dc_ax := PlotterGetDC;
    
    RectangleDC(dc_ax, x, y, size_x, size_y, fig.get_facecolor);
    
    RectangleDC(dc_ax, ac.AbsoluteOrigin.Item1, ac.AbsoluteOrigin.Item2 - field_y, field_x, field_y, ac.GetAxes.get_facecolor);
    
    //отрисовка чёрточек и сетки
    var temp := origin.Item1;
    //while temp <= field_x + x_border do
    for var i := 0 to ac.XNums.Length-1 do 
    begin
      if temp > field_x + x_border then
        break;
      //dc_ax.DrawLine(new Pen(ColorBrush(Colors.Black),ac.LineWidth), Pnt(x+temp, y+origin.Item2), Pnt(x+temp, y+origin.Item2+y_border*0.3));
      LineDC(dc_ax, x + temp, y + origin.Item2, x + temp, y + origin.Item2 + y_border * 0.3, Colors.Black);
      //dc_ax.DrawText(ftext, Pnt(x+temp-ftext.Width/2, y+origin.Item2+y_border*0.35));
      TextOutDC(dc_ax, x + temp - TextWidth(''+ac.XNums[i]) / 2, y + origin.Item2 + y_border * 0.35, ac.XNums[i]);
      
      //сетка
      if ac.GetAxes.grid then
        LineDC(dc_ax, x + temp, y + origin.Item2, x + temp, y + y_border, Colors.Gray);
      //dc_ax.DrawLine(new Pen(ColorBrush(Colors.Gray),ac.LineWidth*0.8), Pnt(x+temp, y+origin.Item2), Pnt(x+temp, y+y_border));
      
      temp += ac.Step.Item1 * x_mult;
    end;
    
    temp := origin.Item2;
    for var i := 0 to ac.YNums.Length-1 do 
    begin
      if temp < y_border then
        break;
      //dc_ax.DrawLine(new Pen(ColorBrush(Colors.Black),ac.LineWidth), Pnt(x+origin.Item1, y+temp), Pnt(x+origin.Item1-x_border*0.3, y+temp));
      LineDC(dc_ax, x + origin.Item1, y + temp, x + origin.Item1 - x_border * 0.3, y + temp, Colors.Black);
      //dc_ax.DrawText(ftext, Pnt(x + origin.Item1 - x_border * 0.4 - ftext.Width, y + temp - ftext.Height / 2));
      TextOutDC(dc_ax, x + origin.Item1 - x_border * 0.4 - TextWidth(''+ac.YNums[i]), y + temp - TextHeight(''+ac.YNums[i]) / 2, ac.YNums[i]);
      
      //сетка
      if ac.GetAxes.grid then
        LineDC(dc_ax, x + origin.Item1, y + temp, x + x_border + field_x, y + temp, Colors.Gray);
      //dc_ax.DrawLine(new Pen(ColorBrush(Colors.Gray),ac.LineWidth*0.8), Pnt(x+origin.Item1, y+temp), Pnt(x+x_border+field_x, y+temp));
      
      temp -= ac.Step.Item2 * y_mult;
    end;
    dc_ax.Close;
  end);
  
end;

//Отрисовка кривых одной координатной сетки
procedure DrawCurves(ac: AxesContainer);
begin
  for var i := 0 to ac.GetAxes.Get_Curves.Count - 1 do
  begin
    var crv := ac.GetAxes.Get_Curves[i];
    case (crv.GetCurveType) of
      CurveType.LineGraph: DrawLineGraph(ac, i);
      CurveType.ScatterGraph: DrawScatterGraph(ac, i);
    end;
  end;
end;

//Отрисовка линейного графика
procedure DrawLineGraph(ac: AxesContainer; ind: integer);
begin
  var func_step := ac.GetFuncStep;
  var crv := ac.GetAxes.Get_Curves[ind];
  var o_x := ac.absoluteOrigin.Item1;
  var o_y := ac.absoluteOrigin.Item2;
  
  var (x_border, y_border) := ac.borders;
  var (xx, yy) := ac.Position;
  var (size_x, size_y) := ac.Size;
  
  if crv.IsFunctional then
  begin
    var ax := ac.GetAxes;
    var (x_min, x_max) := ax.Get_XLim;
    var (y_min, y_max) := ax.Get_YLim;
    var (x_bounded, y_bounded) := (ax.is_x_bounded, ax.is_y_bounded);
    
    //var dc_curve := ac.CurveGroup(ind).Open;
    PlotterInvokeVisual(()->
    begin
      var dc_curve := PlotterGetDC;
  
      var x := x_min;
      var y: real?;
      var (prev_x, prev_y) :=  (0.0,0.0);
      
      while (true) do
      begin
        var draw_x := o_x + (x - ac.originxy.Item1) * ac.step.Item1;
        
        if (x_bounded and (x >= x_max))
            or (draw_x > xx + size_x - x_border) then
          break;
        
        y := crv.GetY(x);
        if (not y.HasValue) or 
           (y_bounded and ((y.Value < y_min) or (y.Value > y_max))) then
        begin
          x += func_step;
          continue;
        end;
        
        var draw_y := o_y - (y.Value - ac.originxy.Item2) * ac.step.Item2;
        
        //костыль
        if (draw_x < xx + x_border)  or
            (draw_y < yy + y_border) or 
            (draw_y > yy + size_y - y_border) then
        begin
          x += func_step;
          continue;
        end;
        
        if (prev_x, prev_y) = (0.0,0.0) then
          (prev_x, prev_y) := (draw_x, draw_y);


        LineDC(dc_curve, prev_x, prev_y, draw_x, draw_y, crv.get_facecolor);
        
        (prev_x, prev_y) := (draw_x, draw_y);
        x += func_step;
      end;
      dc_curve.Close;  
    end);
    
    exit;
  end;
  
  //var dc_curve := ac.CurveGroup(ind).Open;
  PlotterInvokeVisual(()->
  begin
    var dc_curve := PlotterGetDC;
    var x1 := (crv.X[0] - ac.originxy.Item1) * ac.step.Item1;
    var y1 := (crv.Y[0] - ac.originxy.Item2) * ac.step.Item2;
    for var i := 1 to crv.X.Length - 1 do
    begin
      var x := (crv.X[i] - ac.originxy.Item1) * ac.step.Item1;
      var y := (crv.Y[i] - ac.originxy.Item2) * ac.step.Item2;
      //dc_curve.DrawLine(new Pen(ColorBrush(crv.get_facecolor),1.0), Pnt(o_x + x1, o_y - y1), Pnt(o_x + x, o_y - y));
      LineDC(dc_curve, o_x + x1, o_y - y1, o_x + x, o_y - y, crv.get_facecolor);
      x1 := x; y1 := y;
    end;
    dc_curve.Close;
  end);
end;

procedure DrawScatterGraph(ac: AxesContainer; ind: integer);
begin
  
  var crv := ac.GetAxes.Get_Curves[ind];
  var o_x := ac.absoluteOrigin.Item1;
  var o_y := ac.absoluteOrigin.Item2;
  var markersize := ac.GetMarkerSize(ind);
  
  var (x_border, y_border) := ac.borders;
  var (xx, yy) := ac.Position;
  var (size_x, size_y) := ac.Size;
  
  if crv.IsFunctional then
  begin
    var func_step := ac.GetScatterSpace(ind);
    var ax := ac.GetAxes;
    var (x_min, x_max) := ax.Get_XLim;
    var (y_min, y_max) := ax.Get_YLim;
    var (x_bounded, y_bounded) := (ax.is_x_bounded, ax.is_y_bounded);
    
    PlotterInvokeVisual(()->
    begin
      var dc_curve := PlotterGetDC;
  
      var x := x_min;
      var y: real?;
      
      while (true) do
      begin
        var draw_x := o_x + (x - ac.originxy.Item1) * ac.step.Item1;
        
        if (x_bounded and (x >= x_max))
            or (draw_x > xx + size_x - x_border) then
          break;
        
        y := crv.GetY(x);
        if (not y.HasValue) or 
           (y_bounded and ((y.Value < y_min) or (y.Value > y_max))) then
        begin
          x += func_step;
          continue;
        end;
        
        var draw_y := o_y - (y.Value - ac.originxy.Item2) * ac.step.Item2;
        
        //костыль
        if (draw_x < xx + x_border)  or
            (draw_y < yy + y_border) or 
            (draw_y > yy + size_y - y_border) then
        begin
          x += func_step;
          continue;
        end;

        FillEllipseDC(dc_curve, draw_x, draw_y, markersize, markersize, crv.get_facecolor);
        
        x += func_step;
      end;
      dc_curve.Close;  
    end);
    exit;
  end;
  
  PlotterInvokeVisual(()->
  begin
    var dc_curve := PlotterGetDC;
    for var i := 1 to crv.X.Length - 1 do
    begin
      var x := (crv.X[i] - ac.originxy.Item1) * ac.step.Item1;
      var y := (crv.Y[i] - ac.originxy.Item2) * ac.step.Item2;

      FillEllipseDC(dc_curve, o_x+x, o_y-y, markersize, markersize, crv.get_facecolor);
    end;
    dc_curve.Close;
  end);
end;

{
//Возвращает группу кривой индекса i
function AxesContainer.CurveGroup(i: integer): DrawingGroup;
begin
  if (i < 0) or (i >= fcurvesGroups.Count()) then
    raise new Exception('Выход за границы списка групп отрисовки кривых!');
  Result := fcurvesGroups[i];
end;
}

procedure WindowSize(width, height: integer);
begin
  Window.SetSize(width, height);
  
  w := width;
  h := height;
end;

//////////////////////////////////

function AxesContainer.GetXYByMouse(x, y: real): (real?, real?);
begin
  var x1, y1: real?;
  if (x >= AbsoluteOrigin.Item1) 
      and (x <= AbsoluteOrigin.Item1 + FieldSize.Item1)
      and (y <= AbsoluteOrigin.Item2)
      and (y >= AbsoluteOrigin.Item2 - FieldSize.Item2) then
  begin
    x1 := OriginXY.Item1 + (x - AbsoluteOrigin.Item1) / Step.Item1;
    y1 := OriginXY.Item2 + (AbsoluteOrigin.Item2 - y) / Step.Item2;
  end 
  else
  begin
    x1 := nil;
    y1 := nil;
  end;
  
  Result := (x1, y1);
end;

procedure AxesContainer.SetNumSize;
begin
  var (x_border, y_border) := borders;
  
  var size1 := y_border;
  Font := new FontOptions();
  Font.Size := size1;
  var cur_height := TextHeight(''+fxnums[0]);
  while (cur_height > y_border * 0.7) do
  begin
    Font.Size -= 0.1;
    cur_height := TextHeight(''+fxnums[0]);
  end;
  while (cur_height < y_border * 0.6) do
  begin
    Font.Size += 0.1;
    cur_height := TextHeight(''+fxnums[0]);
  end;
  
  var longest_num := fynums[fynums.Length - 1];
  if TextWidth(''+longest_num) < TextWidth(''+fynums[0]) then
    longest_num := fynums[0];
  
  var cur_width := TextWidth(''+longest_num);
  
  while (cur_width > x_border * 0.7) do
  begin
    Font.Size -= 0.1;
    cur_width := TextWidth(''+longest_num);
  end;
  
  ffoptnums := Font;
end;

procedure AxesContainer.SetNums;
begin
  var num := OriginXY.Item1;
  fxnums := new real[fcountaxesnums.Item1];
  for var i := 0 to fcountaxesnums.Item1-1 do
  begin
    fxnums[i] := num;
    num += faxesmultipliers.Item1;
  end;
  
  num := OriginXY.Item2;
  fynums := new real[fcountaxesnums.Item2];
  for var i := 0 to fcountaxesnums.Item1-1 do
  begin
    fynums[i] := num;
    num += faxesmultipliers.Item2;
  end;
end;

procedure AxesContainer.Init(x, y, size_x, size_y: real; ax: Axes);
begin
  fax := ax;
  fposition := (x, y);
  fsize := (size_x, size_y);
  fborders := (size_x * 0.05, size_y * 0.05);
  forigin := (fborders.Item1, size_y - fborders.Item2);
  
      //отступы от краёв
  var x_border := size_x * 0.05;
  var y_border := size_y * 0.05;
      //размеры поля
  var field_x := size_x - x_border * 2;
  var field_y := size_y - y_border * 2;
  ffield := (field_x, field_y);
  
      //длина единицы
  var step_x := field_x / 20;
  var step_y := field_y / 10;
  
  
      //определение границ графика, если есть
  var flag := false;
  var min_x := real.MaxValue;
  var max_x := real.MinValue;
  var min_y := real.MaxValue;
  var max_y := real.MinValue;
  
  for var j := 0 to ax.Get_Curves.Count - 1 do
  begin
    var curve := ax.Get_Curves[j];
    
    if curve.IsFunctional then
      continue;
    flag := true;
    if curve.X[0] < min_x then
      min_x := curve.X[0];
    if curve.X[curve.X.Length - 1] > max_x then
      max_x := curve.X[curve.X.Length - 1];
    
    for var i := 0 to curve.Y.Length - 1 do
    begin
      if curve.Y[i] < min_y then
        min_y := curve.Y[i];
      if curve.Y[i] > max_y then
        max_y := curve.Y[i];
    end;
  end;
  
  
  
      //шаг,если заданы значения
  if flag then
  begin
    if not ax.is_x_bounded then
      step_x := field_x / Floor(Abs(max_x - min_x) + 2);
    
    if not ax.is_y_bounded then
      step_y := field_y / Floor(Abs(max_y - min_y) + 2);
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
    step_x := field_x / (ax.Get_XLim.Item2 - ax.Get_XLim.Item1);
    min_x := ax.Get_XLim.Item1;
    max_x := ax.Get_XLim.Item2;
  end;
  
  if (ax.is_y_bounded) then
  begin
    step_y := field_y / (ax.Get_YLim.Item2 - ax.Get_YLim.Item1);
    min_y := ax.Get_YLim.Item1;
    max_y := ax.Get_YLim.Item2;
  end;
  
  if ax.EqualProportion then
    (step_x, step_y) := (min(step_x, step_y), min(step_x, step_y));
  
  foriginxy := (Floor(min_x) * 1.0, Floor(min_y) * 1.0);
  fstep := (step_x, step_y);
  ffuncstep := (max_x-min_x)/(field_x*0.8);
  fptsize := min(field_x, field_y)/200; 
  fminmaxx := (min_x, max_x);
  fminmaxy := (min_y, max_y);
end;

procedure AxesContainer.AxesNumberMultiplier;
begin
  var (step_x, step_y) := Step;
  var (field_x, field_y) := FieldSize;
  
  var x_mult1 := 1;
  var x_mult2 := 1;
  
  while field_x / (step_x * x_mult1 * x_mult2) > fcountaxesnums.Item1 do
  begin
    case x_mult1 of
      1: x_mult1 := 2;
      2: x_mult1 := 5;
    else 
      (x_mult1, x_mult2) := (1, x_mult2 * 10);
    end;
  end;
  
  var y_mult1 := 1;
  var y_mult2 := 1;
  
  while field_y / (step_y * y_mult1 * y_mult2) > fcountaxesnums.Item2 do
  begin
    case y_mult1 of
      1: y_mult1 := 2;
      2: y_mult1 := 5;
    else 
      (y_mult1, y_mult2) := (1, y_mult2 * 10);
    end;
  end;
  
  faxesmultipliers := (x_mult1 * x_mult2*1.0, y_mult1 * y_mult2*1.0);
end;

procedure AxesContainer.SetSpaces;
begin
end;

function AxesContainer.GetMarkerSize(ind: integer): real;
begin
  Result := GetAxes.Get_Curves[ind].get_markersize*GetPtSize;
end;

function AxesContainer.GetScatterSpace(ind: integer): real;
begin
  var (min_x, max_x) := fminmaxx;
  var (field_x, field_y) := ffield;
  var markersize := GetMarkerSize(ind);
  var space := GetAxes.Get_Curves[ind].spacesize*GetPtSize;
  Result := (max_x-min_x)/min(field_x/(space + markersize),field_y/(space + markersize));
end;


initialization
  {
  MainWindow.Content := host;
  WindowSize(800, 600);


  mainDrawing.Children.Add(mainGroup);
  var vis_cont := new VisualContainer(mainDrawing);
  Host.children.Add(vis_cont);
  }

end. 