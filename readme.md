# Plotter PascalABC
Модуль для визуализации графиков на языке PascalABC.
Курсовая работа 3 курс, Мехмат ЮФУ.

***

**Curve** - класс кривой графика


Name: string - вернуть/задать название кривой

Func: real -> real - функция, задающая график

X: array of real - заданные значения X

Y: array of real - заданные значения Y

MarkerSize: real - вернуть/задать размер маркеров

SpaceSize: real - вернуть/задать размер промежутков между маркерами

GetFacecolor: Color - вернуть цвет кривой

LineWidth: real - вернуть/задать толщину линии графика

Width: real - вернуть/задать ширину столбцов

GetBarLabels: array of string - вернуть подписи столбцов


GetY(x: real): real? - возвращает значение функции в точке

IsFunctional(): boolean - возвращает true, если задана функцией

HasName(): boolean - возвращает true, если есть название кривой


SetFacecolor(col: Color) - установить цвет кривой

SetBarLabels(labels: array of string) - установить подписи столбцов

***

**Axes** - класс области отрисовки графика


Title: string - Вернуть/задать название координатной области

Grid: boolean - Отображение координатной сетки

EqualProportion: boolean - пропорциональное отображение по обеим осям

GetFacecolor: Color - вернуть цвет фона

GetCurves: List<Curve> - Вернуть список кривых

IsXBounded: boolean - Ограничен ли X

IsYBounded: boolean - Ограничен ли Y

GetXLim: (real, real) - Вернуть границы по оси Х

GetYLim: (real, real) - Вернуть границы по оси Y

NeedLegend: boolean - Отображение легенды

TrackMouse: boolean - Отображение текущей позиции курсора мыши в координатах графика


Plot(f: real-> real; cl: Color := Colors.Red): Curve - Построить линейный график по функции

Plot(y: array of real; cl: Color := Colors.Red): Curve - Построить линейный график по массиву Y

Plot(x, y: array of real; cl: Color := Colors.Red): Curve - Построить линейный график по массивам X и Y

Scatter(f: real-> real; cl: Color := Colors.Red): Curve - Построить точечный график по функции

Scatter(y: array of real; cl: Color := Colors.Red): Curve - Построить точечный график по массиву Y

Scatter(x, y: array of real; cl: Color := Colors.Red): Curve - Построить точечный график по массивам X и Y

Bar(y: array of real; cl: Color := Colors.Red): Curve - Построить столбчатый график по массиву Y

Bar(x, y: array of real; cl: Color := Colors.Red): Curve - Построить столбчатый график по массивам X и Y


SetXLim(a, b: real) - задать границы по оси X

SetYLim(a, b: real) - задать границы по оси Y

SetLegend(legend: array of string) - Задать легенду графика

SetFacecolor(col: Color) - установить цвет фона

***
  
**Figure** - класс области размещения графиков


AddSubplot(): Axes - Добавить график

AddSubplot(rows, cols, pos: integer): Axes - добавляет график в сетку rows x cols в позицию с индексом pos

GetAxesMatrix(): array [,] of integer - Вернуть двумерный массив индексов графиков окна

GetAxes(): List<Axes> - Вернуть список графиков окна

GetFacecolor(): Color - вернуть цвет фона

SetFacecolor(col: Color) - установить цвет фона


***


GetFigure(): Figure - возвращает новую область для графиков

GetSubplots(rows, cols: integer): (Figure, List<Axes>) - создаёт новую область для графиков заданного размера
  
WindowSize(width, height: integer) - задать размеры окна

Show(fig: Figure) - отобразить заданную область для графиков
