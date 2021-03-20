# Plotter PascalABC
Модуль для визуализации графиков на языке PascalABC.

***
GetFigure(): Figure - возвращает новую область для графиков
GetSubplots(rows, cols: integer): (Figure, List<Axes>) - создаёт новую область для графиков заданного размера
WindowSize(width, height: integer) - задать размеры окна
Show(fig: Figure) - отобразить заданную область для графиков

**Curve** - класс кривой графика
Name: string - название графика
Description: string - описание графика
Func: real -> real - функция, задающая график
X: array of real - заданные значения X
Y: array of real - заданные значения Y

GetY(x: real): real? - возвращает значение Y по заданному X

**Axes** - класс области отрисовки графика
Plot(y: array of real): Curve - построить линейный график
Plot(x, y: array of real): Curve - построить линейный график
Scatter(y: array of real): Curve - построить точечный график
Scatter(x, y: array of real): Curve - построить точечный график

SetXLim(a, b: real) - задать границы отображения графика по оси X
SetYLim(a, b: real) - задать границы отображения графика по оси Y
SetTitle(title: string) - задать название графика

GetCurves(): List<Curve> - вернуть список кривых графика
GetXLim(): (real, real) - вернуть границы по оси X
GetYLim(): (real, real) - вернуть границы по оси Y

**Figure** - класс области размещения графиков
Fiure.AddSubplot(rows, cols, pos: integer): Axes - добавляет график в сетку rows x cols в позицию с индексом pos
GetAxesMatrix(): array [,] of integer - возвращает числовую матрицу расположения графиков
function GetAxes(): List<Axes> - возвращает список добавленных графиков