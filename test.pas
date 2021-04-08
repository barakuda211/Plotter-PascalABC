uses Plotter;

begin
  var fig := new Figure();
  //WindowSize(500,500);
  var ax := fig.AddSubplot();
  ax.Plot(new real[8](12,8,9,8,15,34,24,5));
  ax.set_facecolor('green');
  //fig.AddSubplot(2,3,0);
  //fig.AddSubplot(2,3,5);
  //fig.AddSubplot(3,3,6);
  Show(fig);
  
end.