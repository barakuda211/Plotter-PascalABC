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
      crv.set_facecolor(cls[c]);
    end;
    ax.Grid := true;
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
      crv.set_facecolor(cls[c]);
    end;
    ax.Grid := true;
    ax.Set_ylim(-10,10);
    ax.Set_legend(Arr('one','two','three'));
    ax.EqualProportion := true;
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
      crv.set_facecolor(cls[c]);
    end;
    ax.Grid := true;
    ax.Set_ylim(-10,10);
    ax.EqualProportion := true;
  end;
  Show(fig);
end;

procedure test_func_array;
begin
  var fig := new Figure();
  var ax := fig.AddSubplot();
  ax.Plot(new real[10](1,5,2.3,-3,-3.8,0,3,5,1.8,1)).line_width := 0.5;
  ax.Plot((x:real) -> sin(x),Colors.Blue).line_width := 2;
  ax.grid := true;
  ax.EqualProportion := false;
  ax.Set_legend(Arr('array','func'));
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
  Show(fig);
end;

procedure test_colors;
begin
  var fig := new Figure();
  fig.set_facecolor(Colors.Yellow);
  var ax := fig.AddSubplot(2,1,0);
  ax.set_facecolor(Colors.Green);
  ax.Plot(ArrRandomReal(10));
  ax.Plot(ArrRandomReal(10),Colors.Blue);
  ax.Plot(ArrRandomReal(10),Colors.Gray);
  
  ax := fig.AddSubplot(2,1,1);
  ax.set_facecolor(Colors.Orange);
  ax.Plot(ArrRandomReal(10),Colors.Black);
  ax.Plot(ArrRandomReal(10),Colors.Cyan);
  ax.Plot(ArrRandomReal(10),Colors.Lime);
  ax.Grid := true;
  ax.EqualProportion := true;
  
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
  ax.Plot(x,y).line_width := 0.2;
  ax.grid := true;
  Show(fig);
end;

procedure test_grid;
begin
  var fig := new Figure();
  var ax := fig.AddSubplot();
  for var i := -3 to 3 do
    ax.Scatter(ArrFill(6, i*1.0));
  ax.grid := true;
  Show(fig);
end;

procedure test_bars;
begin
  var fig := new Figure();
  var ax := fig.AddSubplot();
  var crv := ax.Bar(new real[10](1,2,3,4,5,6,7,8,9,10));
  crv.set_BarLabels((1..10).Select(x->'bar'+x).ToArray);
  ax.set_legend(Arr('bars'));
  ax.grid := true;
  Show(fig);
end;

begin
  //WindowSize(1280,720);
  //WindowSize(1920,1280);
  
  //test_many_funcs_scatter;
  //test_func_array_scatter;
  test_func_array;
  //FastDraw(dc->test_many_arrays(10,10));
  //test_many_funcs(2,2);
  //test_colors;
  //test_bars;
  //test_long_array;
  //test_grid;
  print(millisecondsdelta);
end.