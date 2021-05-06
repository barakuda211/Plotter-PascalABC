uses Plotter;

procedure test_many_arrays(rows: integer := 4; cols: integer := 4);
begin
  var fig := new Figure();
  var cls := new string[3]('red','green','blue');
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
  var cls := new string[3]('red','green','blue');
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
    ax.EqualProportion := true;
  end;
  Show(fig);
end;

procedure test_func_array;
begin
  var fig := new Figure();
  var ax := fig.AddSubplot();
  ax.Plot(new real[10](1,5,2.3,-3,-3.8,0,3,5,1.8,1));
  ax.Plot((x:real) -> sin(x),'blue');
  ax.grid := true;
  ax.EqualProportion := true;
  Show(fig);
end;

procedure test_colors;
begin
  var fig := new Figure();
  fig.set_facecolor('yellow');
  var ax := fig.AddSubplot(2,1,0);
  ax.set_facecolor('green');
  ax.Plot(ArrRandomReal(10));
  ax.Plot(ArrRandomReal(10),'blue');
  ax.Plot(ArrRandomReal(10),'gray');
  
  ax := fig.AddSubplot(2,1,1);
  ax.set_facecolor('orange');
  ax.Plot(ArrRandomReal(10),'black');
  ax.Plot(ArrRandomReal(10),'cyan');
  ax.Plot(ArrRandomReal(10),'lime');
  ax.Grid := true;
  ax.EqualProportion := true;
  
  Show(fig);
end;

begin
  WindowSize(1280,720);

  //test_func_array;
  //test_many_arrays;
  //test_many_funcs;
  test_colors;
  
end.