unit RendererModule;

interface

uses GraphWPF, FigureModule, AxesModule; 

//шаг отрисовки
var step := 0.1;
//Размеры окна (костыль)
var w, h: real;
//отступы между графиками по осям X и Y
var Borders := (25, 12);

//контейнер для позиционирования графика
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
    
  public
    //вернуть график
    property GetAxes: Axes read fax;
    //позиция графика
    property Position: (real, real) read fposition;
    //размер графика
    property Size: (real, real) read fsize;
    //левый нижний угол координатной области
    property Origin: (real, real) read forigin;
    //отступы от краёв
    property Borders: (real, real) read fborders;
    //размеры координатной области
    property FieldSize: (real, real) read ffield;
    //размер единицы по осям координатной области
    property Step: (real, real) read fstep;
    //значения X и Y в точке origin
    property OriginXY: (real, real) read foriginxy;
    //абсолютные координаты точки отсчёта графика
    property AbsoluteOrigin: (real, real) read (fposition.Item1+forigin.Item1, fposition.Item2+forigin.Item2);
   
    constructor Create(x, y, size_x, size_y: real; ax: Axes);
    begin
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
          step_x := field_x/Floor(Abs(max_x-min_x) + 1)
        else
        begin
          step_x := field_x/(ax.Get_XLim.Item2 - ax.Get_XLim.Item1);
          min_x := ax.Get_XLim.Item1;
          max_x := ax.Get_XLim.Item2;
        end;
        
        if not ax.is_y_bounded then
          step_y := field_y/Floor(Abs(max_y-min_y) + 1)
        else
        begin
          step_y := field_y/(ax.Get_YLim.Item2 - ax.Get_YLim.Item1);
          min_y := ax.Get_YLim.Item1;
          max_y := ax.Get_YLim.Item2;
        end;
      end
      else
      begin
        min_x := ax.Get_XLim.Item1;
        max_x := ax.Get_XLim.Item2;
        min_y := ax.Get_YLim.Item1;
        max_y := ax.Get_YLim.Item2;
      end;
      
      foriginxy := (Floor(min_x)*1.0, Floor(min_y)*1.0);
      fstep := (step_x, step_y);
  
    end;
end;

//Отобразить окно с графиком
procedure Show(fig: Figure);

//нарисовать график
procedure DrawAxes(x, y, size_x, size_y: real; ax: Axes; fig: Figure);

//нарисовать сетку графиков
procedure DrawMash(rows, cols: integer; x_size, y_size: real);

//Задать размеры окна
procedure WindowSize(width, height: integer);

//Отрисовка кривых одной координатной сетки
procedure DrawCurves(ac: AxesContainer);
 
//Отрисовка координатного интерфейса
procedure DrawCoordinates(ac: AxesContainer; fig: Figure); 

//Отрисовка линейного графика
procedure DrawLineGraph(ac: AxesContainer; crv: Curve);
 
implementation

procedure WindowSize(width, height: integer);
begin
  Window.Width := width;
  Window.Height := height;
  w := width;
  h := height;
end;

procedure Show(fig: Figure);
begin
  FillRectangle(0,0,w, h, fig.get_facecolor);
  
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
  
  FillRectangle(x,y,size_x,size_y, fig.get_facecolor);
  
  Rectangle(x+x_border, y+y_border, size_x-2*x_border, size_y-2*y_border, ac.GetAxes.get_facecolor);
  //отрисовка чёрточек
  var temp := origin.Item1;
  while temp <= field_x+x_border do
  begin
    Line(x+temp, y+origin.Item2, x+temp, y+origin.Item2+y_border*0.3);
    temp += ac.Step.Item1;
  end;
  
  temp := origin.Item2;
  while temp >= y_border do
  begin
    Line(x+origin.Item1, y+temp, x+origin.Item1-x_border*0.3, y+temp);
    temp -= ac.Step.Item2;
  end;
  
end;

//Отрисовка кривых одной координатной сетки
procedure DrawCurves(ac: AxesContainer);
begin
  foreach crv: Curve in ac.GetAxes.Get_Curves do
  begin
    case (crv.GetCurveType) of
      CurveType.LineGraph: DrawLineGraph(ac, crv)
    end;
  end;
end;

//Отрисовка линейного графика
procedure DrawLineGraph(ac: AxesContainer; crv: Curve);
begin
  var o_x := ac.absoluteOrigin.Item1;
  var o_y := ac.absoluteOrigin.Item2;
  if crv.IsFunctional then
    exit;
  
  var x1 := (crv.X[0]-ac.originxy.Item1)*ac.step.Item1;
  var y1 := (crv.Y[0]-ac.originxy.Item2)*ac.step.Item2;
  for var i := 1 to crv.X.Length-1 do
  begin
    var x := (crv.X[i]-ac.originxy.Item1)*ac.step.Item1;
    var y := (crv.Y[i]-ac.originxy.Item2)*ac.step.Item2;
    Line(o_x + x1, o_y - y1, o_x + x, o_y - y, crv.get_facecolor);
    x1 := x; y1 := y;
  end;
  
end;


//нарисовать сетку графиков
procedure DrawMash(rows, cols: integer; x_size, y_size: real);
begin
  var x := Borders.Item1*1.0;
  for var i:=0 to cols-1 do
  begin
    Line(x,0,x,h);
    x += x_size;
    Line(x,0,x,h);
    x += Borders.Item1;
  end;
  Line(x,0,x,h);
  
  var y := Borders.Item2*1.0;
  for var i:=0 to rows-1 do
  begin
    Line(0,y,w,y);
    y += y_size;
    Line(0,y,w,y);
    y += Borders.Item2;
  end;
  Line(0,y,w,y);
end;

initialization
  w := Window.Width;
  h := Window.Height;
  Window.Title := 'Plotter';


end.