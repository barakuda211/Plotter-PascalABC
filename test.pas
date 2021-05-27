uses GraphWPF,Plotter;

procedure test_many_arrays(rows: integer := 4; cols: integer := 4);
begin
  var fig := new Figure();
  var cls := new Color[3](Colors.Red,Colors.Green,Colors.Blue);
  for var i := 0 to rows*cols-1 do
  begin
    var ax := fig.AddSubplot(rows,cols,i);
    for var c := 0 to 2 do
    begin 
      var len := Random(50,150);
      var step := Random(0.8, 1.2);
      var x := new real[len];
      var y := new real[len];
      var start:= Random(15.0);
      for var j :=0 to len-1 do
      begin
        x[j] := start;
        y[j] := Random(Random(-200, 0),Random(1,200));
        start += step;
      end;
      var crv := ax.Plot(x,y);
      crv.SetFacecolor(cls[c]);
    end;
    ax.Grid := true;
    ax.TrackMouse := false;
  end;
  Show(fig);
end;

procedure test_many_funcs(rows: integer := 2; cols: integer := 2);
begin
  var fig := new Figure();
  var cls := new Color[3](Colors.Red,Colors.Green,Colors.Blue);
  for var i := 0 to rows*cols-1 do
  begin
    var ax := fig.AddSubplot(rows,cols,i);
    for var c := 0 to 2 do
    begin 
      var cos_sin := Random(2);
      var len := Random(2,5);
      var koef := Random(-10.0,10.0);
      var crv : Curve;
      if cos_sin = 1 then
        crv := ax.Plot((x: real)->(koef*power(cos(x),len)))
      else
        crv := ax.Plot((x: real)->(koef*power(sin(x),len)));    
      crv.SetFacecolor(cls[c]);
    end;
    ax.Grid := true;
    ax.Setylim(-12,12);
    ax.EqualProportion := true;
    ax.TrackMouse := false;
  end;
  Show(fig);
end;

procedure test_many_funcs_scatter(rows: integer := 2; cols: integer := 2);
begin
  var fig := new Figure();
  var cls := new Color[3](Colors.Red,Colors.Green,Colors.Blue);
  for var i := 0 to rows*cols-1 do
  begin
    var ax := fig.AddSubplot(rows,cols,i);
    for var c := 0 to 2 do
    begin 
      var cos_sin := Random(2);
      var len := Random(2,5);
      var koef := Random(-10.0,10.0);
      var crv : Curve;
      if cos_sin = 1 then
        crv := ax.Scatter((x: real)->(koef*power(cos(x),len)))
      else
        crv := ax.Scatter((x: real)->(koef*power(sin(x),len)));    
      crv.SetFacecolor(cls[c]);
    end;
    ax.Grid := true;
    ax.Setylim(-12,12);
    ax.EqualProportion := true;
    ax.Title := 'Functions '+i;
    ax.SetLegend(Arr('one','two','three'));
  end;
  Show(fig);
end;

procedure test_func_array;
begin
  var fig := new Figure();
  var ax := fig.AddSubplot();
  ax.Plot(new real[10](1,5,2.3,-3,-3.8,0,3,5,1.8,1)).linewidth := 0.5;
  ax.Plot((x:real) -> sin(x),Colors.Blue).linewidth := 2;
  ax.grid := true;
  ax.EqualProportion := false;
  ax.SetLegend(Arr('array','func'));
  ax.Title := 'Func and array';
  Show(fig);
end;

procedure test_func_array_scatter;
begin
  var fig := new Figure();
  var ax := fig.AddSubplot();
  ax.Scatter(new real[10](1,5,2.3,-3,-3.8,0,3,5,1.8,1));
  var crv := ax.Scatter((x:real) -> sin(x),Colors.Blue);
  ax.grid := true;
  ax.EqualProportion := true;
  ax.Title := 'Func and array scatter';
  Show(fig);
end;

procedure test_colors;
begin
  var fig := new Figure();
  fig.SetFacecolor(Colors.Yellow);
  var ax := fig.AddSubplot(2,1,0);
  ax.SetFacecolor(Colors.Green);
  ax.Plot(ArrRandomReal(10));
  ax.Plot(ArrRandomReal(10),Colors.Blue);
  ax.Plot(ArrRandomReal(10),Colors.Gray);
  ax.Title:='First random color';
  
  ax := fig.AddSubplot(2,1,1);
  ax.SetFacecolor(Colors.Orange);
  ax.Plot(ArrRandomReal(10),Colors.Black);
  ax.Plot(ArrRandomReal(10),Colors.Cyan);
  ax.Plot(ArrRandomReal(10),Colors.Lime);
  ax.Grid := true;
  ax.EqualProportion := true;
  ax.Title:='Second random color';
  
  Show(fig);
end;

procedure test_long_array;
begin
  var fig := new Figure();
  var ax := fig.AddSubplot();
  var x := new real[1000];
  var y := new real[1000];
  x[0] := 0; y[0] := 0;
  for var i:= 1 to 999 do
  begin
    y[i] := Random(0.001,-0.001);
    x[i] := x[i-1]+0.008;
  end;
  ax.Plot(x,y).linewidth := 0.2;
  ax.grid := true;
  ax.Title := 'Test long array';
  Show(fig);
end;

procedure test_grid;
begin
  var fig := new Figure();
  var ax := fig.AddSubplot();
  for var i := -3 to 3 do
    ax.Scatter(ArrFill(6, i*1.0));
  ax.grid := true;
  ax.Title := 'Dots on intersections';
  Show(fig);
end;

procedure test_bars;
begin
  var fig := new Figure();
  var ax := fig.AddSubplot();
  var crv := ax.Bar(new real[10](1,2,3,4,5,6,7,8,9,10));
  crv.SetBarLabels((1..10).Select(x->'bar'+x).ToArray);
  ax.Title := 'Test bars';
  Show(fig);
end;

procedure test_distribution;
begin
  var fig := new Figure();
  var ax := fig.AddSubplot();
  var y := new real[100];
  foreach var x in ArrRandomReal(10000,0,100) do
    for var i := 0 to 99 do
      if x < i+1 then
      begin
        y[i] += 1;
        break;
      end;  
  ax.Bar(y);
  ax.Title := 'Test Distribution';
  ax.TrackMouse := false;
  Show(fig);
end;


procedure test_diff_sizes;
begin
  var fig := new Figure();
  var y1 := ArrRandomReal(100);
  var y2 := ArrRandomReal(100);
  var y3 := ArrRandomReal(100);
  var ax := fig.AddSubplot(2,1,0);
  var avg := y1.Zip(y2,(a,b)->(a+b)/2).Zip(y3,(a,b)->(a+b)/2);
  var c := ax.Plot(avg.ToArray);
  c.LineWidth := 3;
  ax.Grid := true;
  ax.Title := 'Average';
  ax := fig.AddSubplot(2,3,3);
  ax.Plot(y1);
  ax := fig.AddSubplot(2,3,4);
  ax.Plot(y2,Colors.Green);
  ax := fig.AddSubplot(2,3,5);
  ax.Plot(y3, Colors.Blue);
  Show(fig);
end;

begin
  WindowSize(800, 600);
  //WindowSize(1280,1024);
  //WindowSize(1920,1280);
  
  //test_many_funcs_scatter;
  //test_func_array_scatter;
  //test_func_array;
  //test_many_arrays(5,5);
  //test_many_funcs(5,5);
  //test_colors;
  //test_bars;
  //test_long_array;
  //test_grid;
  //test_diff_sizes;
  test_distribution;
  print(millisecondsdelta);
end.