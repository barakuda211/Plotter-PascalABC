uses Plotter;

procedure test_func1;
begin
  var fig := new Figure();
  var ax := fig.AddSubplot();
  var c := ax.Plot((x:real) -> x*x,'green');
  ax.Set_Xlim(-5,5);
  ax.Set_ylim(0,100);
  Show(fig);
end;

procedure test_func2;
begin
  var fig := new Figure();
  var ax := fig.AddSubplot();
  var c := ax.Plot((x:real) -> sin(x),'blue');
  ax.Set_Xlim(-10,19);
  ax.Set_ylim(-2,2);
  ax.grid := true;
  Show(fig);
end;

procedure test_arr;
begin
  var fig := new Figure();
  var ax := fig.AddSubplot();
  ax.Plot(new real[10](62,42,-3,43,5,13,56,-10,12,2));
  ax.Plot((x:real) -> sin(x),'blue');
  ax.grid := true;
  ax.EqualProportion := true;
   ax.Set_Xlim(-10,50);
  Show(fig);
end;

begin
  //test_func1;
  //test_func2;
  //test_arr;
  
  
  
end.