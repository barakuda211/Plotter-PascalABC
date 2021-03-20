unit FigureModule;

interface 

uses AxesModule;

//Класс области размещения графиков
type
  Figure = class
  private
    //Список графиков окна
    axesList: List<Axes>;
    
    //Двумерный массив индексов графиков окна
    axesMatrix: array [,] of integer;
    
    //инициализация матрицы индексов
    procedure InitAxesMatrix();
    //инициализация матрицы с заданным размером
    procedure InitAxesMatrix(rows, cols: integer; var am: array [,] of integer);
    //подстроить размер массива графиков
    function FitInAxesMatrix(rows, cols, pos: integer): integer;
    
    //возвращает позицию графика в сетке и его размеры
    function SizeOfAxes(id: integer): (integer, integer, integer);
  
    function NOD(x, y:integer): integer;
    function NOK(x, y:integer): integer;
  
  public
    constructor Create();
    begin
      InitAxesMatrix;
      axesList := new List<Axes>();
    end;
  
    //Добавить график
    function AddSubplot(rows, cols, pos: integer): Axes;
    //Вернуть двумерный массив индексов графиков окна
    function GetAxesMatrix(): array [,] of integer;
    //Вернуть список графиков окна
    function GetAxes(): List<Axes>;
    
    
  
  end;

implementation
  
function Figure.AddSubplot(rows, cols, pos: integer): Axes;
begin
  if (rows*cols-1 < pos) or (pos < 0) then
  begin
    raise new Exception('Ошибка! Некорректная позиция графика.');
    exit;
  end;
  
  
  if (axesList.Count = 0) then
  begin
    InitAxesMatrix(rows, cols, axesMatrix);
    axesList.Add(new Axes());
    axesMatrix[pos div cols, pos mod cols] := 0;
    Result := axesList[0];
    exit;
  end;
  
  FitInAxesMatrix(rows, cols, pos);
  axesList.Add(new Axes());
  Result := axesList[axesList.Count-1];
end;

function Figure.GetAxesMatrix(): array [,] of integer := axesMatrix;

function Figure.GetAxes(): List<Axes> := axesList;

//инициализация матрицы индексов
procedure Figure.InitAxesMatrix();
begin
  axesMatrix := new integer[0,0];
end;

//инициализация матрицы с заданным размером
procedure Figure.InitAxesMatrix(rows, cols: integer; var am: array [,] of integer);
begin
  am := new integer[rows, cols];
  for var i := 0 to rows-1 do
    for var j := 0 to cols-1 do
      am[i, j] := -1;
end;

//подстроить размер матрицы графиков
function Figure.FitInAxesMatrix(rows, cols, pos: integer): integer;
begin
  if (axesMatrix.ColCount = cols) and (axesMatrix.RowCount = rows) then
  begin
    if axesMatrix[pos div cols, pos mod cols] <> -1 then
      raise new Exception('Ошибка! Пересечение графиков в окне.');
    axesMatrix[pos div cols, pos mod cols] := axesList.Count;
    exit;
  end;
  
  //подбор минимального возможного размера матрицы графиков
  var col_nok := NOK(cols, axesMatrix.ColCount);  
  var row_nok := NOK(rows, axesMatrix.RowCount);

  var newMatrix: array [,] of integer;
  InitAxesMatrix(row_nok,col_nok, newMatrix);
  
  //перенос уже имеющихся графиков в новую матрицу
  for var k := 0 to axesList.Count-1 do
  begin
    (var ind, var x, var y) := SizeOfAxes(k);
    var new_row_size := (y*row_nok) div axesMatrix.RowCount;
    var new_col_size := (x*col_nok) div axesMatrix.ColCount;
    
    var new_row := (ind div axesMatrix.ColCount)*(max(row_nok,axesMatrix.RowCount) div min(row_nok,axesMatrix.RowCount));
    var temp1 := (max(col_nok,axesMatrix.ColCount) div min(col_nok,axesMatrix.ColCount));
    var temp2 := (ind mod axesMatrix.ColCount);
    var new_col := temp1*temp2;
    
    for var i := 0 to new_row_size-1 do
      for var j := 0 to new_col_size-1 do
        newMatrix[new_row+i,new_col+j] := k;
  end;
  
  //добавляем новый график в матрицу
  //var row_size := row_nok div axesMatrix.RowCount;
  //var col_size := col_nok div axesMatrix.ColCount;
  var row_size := row_nok div rows;
  var col_size := col_nok div cols;
  
  
  var new_row := (pos div cols)*(max(row_nok,rows) div min(rows,row_nok));
  var new_col := (pos mod cols)*(max(col_nok,cols) div min(cols,col_nok));
  
  for var i := 0 to row_size-1 do
    for var j := 0 to col_size-1 do
    begin
      if newMatrix[new_row + i, new_col + j] <> -1 then
        raise new Exception('Ошибка! Пересечение графиков в окне.');
      newMatrix[new_row + i, new_col + j] := axesList.Count;
    end;
  
  //заменяем старую матрицу новой расширенной  
  axesMatrix := newMatrix;
  
end;

//возвращает позицию графика в сетке и его размеры
function Figure.SizeOfAxes(id: integer): (integer, integer, integer);
begin
  var x,y,pos: integer;
  for var i := 0 to axesMatrix.RowCount-1 do
  begin
    var founded := false;
    for var j := 0 to axesMatrix.ColCount-1 do
    begin
      if axesMatrix[i,j] <> id then
        continue;
      (x, y) := (j, i);
      pos := i*axesMatrix.ColCount + j;
      founded := true;
      break;
    end;
    if founded then
      break;
  end;
  
  (var size_x, var size_y) := (0,0);
  while (x < axesMatrix.ColCount) and (axesMatrix[y,x] = id) do
  begin
    x += 1;
    size_x += 1;
  end;
  x -= 1;
  while (y < axesMatrix.RowCount) and (axesMatrix[y,x] = id) do
  begin
    y += 1;
    size_y += 1;
  end;
  
  Result := (pos, size_x, size_y);
end;


function Figure.NOD(x, y:integer): integer;
begin
  if x = y then
  begin
    Result := x;
    exit;
  end;
  var d := x-y;
  if d < 0 then
  begin
    d := -d;
    Result := NOD(x, d);
  end
  else
    Result := NOD(y, d);
end;

function Figure.NOK(x, y:integer): integer := (x*y) div NOD(x, y);



end.