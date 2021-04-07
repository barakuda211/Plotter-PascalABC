uses Plotter;

begin
  var fig := new Figure();
  //WindowSize(500,500);
  var ax := fig.AddSubplot(3,3,2);
  fig.set_facecolor('gray');
  ax.Plot(new real[5](14,42,35,1,67));
  fig.AddSubplot(2,3,0);
  fig.AddSubplot(2,3,5);
  fig.AddSubplot(3,3,6);
  Show(fig);
  
end.