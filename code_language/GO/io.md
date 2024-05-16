# IO接口
## io.Reader 和 io.Writer 接口
最底层的原语
Read可能返回 err == EOF 或者 err == nil

实现了 Reader 的类型：LimitedReader、PipeReader、SectionReader
实现了 Writer 的类型：PipeWriter
实现的包有：
- os.File 同时实现了 io.Reader 和 io.Writer
- strings.Reader 实现了 io.Reader
- bufio.Reader/Writer 分别实现了 io.Reader 和 io.Writer
- bytes.Buffer 同时实现了 io.Reader 和 io.Writer
- bytes.Reader 实现了 io.Reader
- compress/gzip.Reader/Writer 分别实现了 io.Reader 和 io.Writer
- crypto/cipher.StreamReader/StreamWriter 分别实现了 io.Reader 和 io.Writer
- crypto/tls.Conn 同时实现了 io.Reader 和 io.Writer
- encoding/csv.Reader/Writer 分别实现了 io.Reader 和 io.Writer
- mime/multipart.Part 实现了 io.Reader
- net/conn 分别实现了 io.Reader 和 io.Writer(Conn接口定义了Read/Write)

## ReaderAt和WriterAt 接口
Read可能返回 err == EOF 或者 err == nil

## ReaderFrom和WriterTo接口

ReadFrom 方法不会返回 err == EOF


## Seeker接口

## Closer接口

## ByteReader 和 ByteWriter接口


- bufio.Reader/Writer 分别实现了io.ByteReader 和 io.ByteWriter
- bytes.Buffer 同时实现了 io.ByteReader 和 io.ByteWriter
- bytes.Reader 实现了 io.ByteReader
- strings.Reader 实现了 io.ByteReader

## ByteScanner、RuneReader 和 RuneScanner接口


## ReadCloser、ReadSeeker、ReadWriteCloser、ReadWriteSeeker、ReadWriter、WriteCloser 和 WriteSeeker 接口
两个或三个组合而成的新接口

## SectionReader 类型

SectionReader 是一个 struct（没有任何导出的字段），实现了 Read, Seek 和 ReadAt，同时，内嵌了 ReaderAt 接口


## LimitedReader 类型

## PipeReader 和 PipeWriter 类型

## Copy 和 CopyN 函数

## ReadAtLeast 和 ReadFull 函数

## WriteString 函数

## MultiReader 和 MultiWriter 函数

# ioutil-方便的操作函数集

# fmt-格式化IO

# bufio-缓存IO