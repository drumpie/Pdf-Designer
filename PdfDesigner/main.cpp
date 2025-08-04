#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <QCommandLineParser>
#include <QCommandLineOption>
// #include <QtSvg>

int main(int argc, char *argv[])
{
    QCoreApplication::setApplicationName("Pdf Designer");
    QCoreApplication::setApplicationVersion(QT_VERSION_STR);

    QGuiApplication app(argc, argv);

    Q_PROPERTY(int currentPage READ currentPage WRITE setCurrentPage NOTIFY currentPageChanged)

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("PdfDesigner", "Main");

    return app.exec();
}
