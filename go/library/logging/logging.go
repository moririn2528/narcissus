package logging

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"runtime"
	"strconv"
)

type Logger interface {
	Debug(v ...interface{})
	Debugf(format string, v ...interface{})
	Info(v ...interface{})
	Infof(format string, v ...interface{})
	Warning(v ...interface{})
	Warningf(format string, v ...interface{})
	Error(v ...interface{})
	Errorf(format string, v ...interface{})
	Critical(v ...interface{})
	Criticalf(format string, v ...interface{})
}

type LocalLogger struct {
	debug *log.Logger
	info  *log.Logger
	std   *log.Logger
}

var (
	infoFile  *os.File
	debugFile *os.File
)

func NewLogger() Logger {
	_, err := os.LookupEnv("GCP_PROJECT")
	if err {
		return NewLocalLogger()
	} else {
		return NewCloudLogger()
	}
}

func NewLocalLogger() *LocalLogger {
	var err error
	if _, err := os.Stat("log"); os.IsNotExist(err) {
		os.Mkdir("log", 0777)
	}
	if infoFile == nil {
		infoFile, err = os.OpenFile("log/info.log", os.O_CREATE|os.O_WRONLY|os.O_APPEND|os.O_CREATE, 0666)
		if err != nil {
			panic(err)
		}
	}
	if debugFile == nil {
		debugFile, err = os.OpenFile("log/debug.log", os.O_CREATE|os.O_WRONLY|os.O_APPEND|os.O_CREATE, 0666)
		if err != nil {
			panic(err)
		}
	}
	return &LocalLogger{
		debug: log.New(debugFile, "", log.Ldate|log.Ltime),
		info:  log.New(infoFile, "", log.Ldate|log.Ltime),
		std:   log.New(os.Stdout, "", log.Ldate|log.Ltime),
	}
}

func getCallerInfo() string {
	_, file, line, _ := runtime.Caller(2)
	// _, file_name := filepath.Split(file)
	return file + ":" + strconv.Itoa(line)
}

func (l *LocalLogger) Debug(v ...interface{}) {
	l.debug.Println(append([]interface{}{"[ DEBUG ]", getCallerInfo()}, v...)...)
}

func (l *LocalLogger) Debugf(format string, v ...interface{}) {
	l.debug.Printf("[ DEBUG ] "+getCallerInfo()+" "+format, v...)
}

func (l *LocalLogger) Info(v ...interface{}) {
	l.debug.Println(append([]interface{}{"[ INFO ]", getCallerInfo()}, v...)...)
	l.info.Println(append([]interface{}{"[ INFO ]", getCallerInfo()}, v...)...)
}

func (l *LocalLogger) Infof(format string, v ...interface{}) {
	l.debug.Printf("[ INFO ] "+getCallerInfo()+" "+format, v...)
	l.info.Printf("[ INFO ] "+getCallerInfo()+" "+format, v...)
}

func (l *LocalLogger) Warning(v ...interface{}) {
	l.debug.Println(append([]interface{}{"[ WARNING ]", getCallerInfo()}, v...)...)
	l.info.Println(append([]interface{}{"[ WARNING ]", getCallerInfo()}, v...)...)
	l.std.Println(append([]interface{}{"[ \x1b[0;33WARNING\x1b[0m ]", getCallerInfo()}, v...)...)
}

func (l *LocalLogger) Warningf(format string, v ...interface{}) {
	l.debug.Printf("[ WARNING ] "+getCallerInfo()+" "+format, v...)
	l.info.Printf("[ WARNING ] "+getCallerInfo()+" "+format, v...)
	l.std.Printf("[ \x1b[0;33WARNING\x1b[0m ] "+getCallerInfo()+" "+format, v...)
}

func (l *LocalLogger) Error(v ...interface{}) {
	l.debug.Println(append([]interface{}{"[ ERROR ]", getCallerInfo()}, v...)...)
	l.info.Println(append([]interface{}{"[ ERROR ]", getCallerInfo()}, v...)...)
	l.std.Println(append([]interface{}{"[ \x1b[0;31mERROR\x1b[0m ]", getCallerInfo()}, v...)...)
}

func (l *LocalLogger) Errorf(format string, v ...interface{}) {
	l.debug.Printf("[ ERROR ] "+getCallerInfo()+" "+format, v...)
	l.info.Printf("[ ERROR ] "+getCallerInfo()+" "+format, v...)
	l.std.Printf("[ \x1b[0;31mERROR\x1b[0m ] "+getCallerInfo()+" "+format, v...)
}

func (l *LocalLogger) Critical(v ...interface{}) {
	l.debug.Println(append([]interface{}{"[ CRITICAL ]", getCallerInfo()}, v...)...)
	l.info.Println(append([]interface{}{"[ CRITICAL ]", getCallerInfo()}, v...)...)
	l.std.Println(append([]interface{}{"[ \x1b[0;31mCRITICAL\x1b[0m ]", getCallerInfo()}, v...)...)
}

func (l *LocalLogger) Criticalf(format string, v ...interface{}) {
	l.debug.Printf("[ CRITICAL ] "+getCallerInfo()+" "+format, v...)
	l.info.Printf("[ CRITICAL ] "+getCallerInfo()+" "+format, v...)
	l.std.Printf("[ \x1b[0;31mCRITICAL\x1b[0m ] "+getCallerInfo()+" "+format, v...)
}

type CloudLogger struct {
	std *log.Logger
}

func NewCloudLogger() *CloudLogger {
	return &CloudLogger{
		std: log.New(os.Stdout, "", 0),
	}
}

type CloudLogMessage struct {
	Message  string `json:"message"`
	Severity string `json:"severity"`
	Where    string `json:"where"`
}

func (mes CloudLogMessage) String() string {
	out, err := json.Marshal(mes)
	if err != nil {
		log.Printf("json.Marshal error in logging: %v", err)
	}
	return string(out)
}

func (l *CloudLogger) Debug(v ...interface{}) {
	l.std.Println(CloudLogMessage{
		Message:  fmt.Sprint(v...),
		Severity: "DEBUG",
		Where:    getCallerInfo(),
	})
}
func (l *CloudLogger) Debugf(format string, v ...interface{}) {
	l.std.Println(CloudLogMessage{
		Message:  fmt.Sprintf(format, v...),
		Severity: "DEBUG",
		Where:    getCallerInfo(),
	})
}
func (l *CloudLogger) Info(v ...interface{}) {
	l.std.Println(CloudLogMessage{
		Message:  fmt.Sprint(v...),
		Severity: "INFO",
		Where:    getCallerInfo(),
	})
}
func (l *CloudLogger) Infof(format string, v ...interface{}) {
	l.std.Println(CloudLogMessage{
		Message:  fmt.Sprintf(format, v...),
		Severity: "INFO",
		Where:    getCallerInfo(),
	})
}
func (l *CloudLogger) Warning(v ...interface{}) {
	l.std.Println(CloudLogMessage{
		Message:  fmt.Sprint(v...),
		Severity: "WARNING",
		Where:    getCallerInfo(),
	})
}
func (l *CloudLogger) Warningf(format string, v ...interface{}) {
	l.std.Println(CloudLogMessage{
		Message:  fmt.Sprintf(format, v...),
		Severity: "WARNING",
		Where:    getCallerInfo(),
	})
}
func (l *CloudLogger) Error(v ...interface{}) {
	l.std.Println(CloudLogMessage{
		Message:  fmt.Sprint(v...),
		Severity: "ERROR",
		Where:    getCallerInfo(),
	})
}
func (l *CloudLogger) Errorf(format string, v ...interface{}) {
	l.std.Println(CloudLogMessage{
		Message:  fmt.Sprintf(format, v...),
		Severity: "ERROR",
		Where:    getCallerInfo(),
	})
}
func (l *CloudLogger) Critical(v ...interface{}) {
	l.std.Println(CloudLogMessage{
		Message:  fmt.Sprint(v...),
		Severity: "CRITICAL",
		Where:    getCallerInfo(),
	})
}
func (l *CloudLogger) Criticalf(format string, v ...interface{}) {
	l.std.Println(CloudLogMessage{
		Message:  fmt.Sprintf(format, v...),
		Severity: "CRITICAL",
		Where:    getCallerInfo(),
	})
}
