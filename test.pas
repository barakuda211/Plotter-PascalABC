uses Plotter;

begin
  var fig := new Figure();
  //WindowSize(500,500);
  var ax := fig.AddSubplot();
  ax.Plot(new real[5](1,2,3,4,5));
  //ax.set_facecolor('green');
  //fig.AddSubplot(2,3,0);
  //fig.AddSubplot(2,3,5);
  //fig.AddSubplot(3,3,6);
  Show(fig);
  
end.