#ifndef WIDGETCONTAINER_H
#define WIDGETCONTAINER_H

#include <QWidget>
#include <QWindow>
#include <Windows.h>
#include <TlHelp32.h>
#include <QEvent>
#include <QMouseEvent>

class WidgetContainer : public QWidget
{
    Q_OBJECT
    struct handle_data {
        DWORD processId;
        HWND wndHandle;
    };
public:
    explicit WidgetContainer(QWidget *parent = nullptr);
    static QWidget* createContainer(const QString &iAppName, bool iAutoOpen = true);
    static DWORD findProcessId(const QString &iAppName);
    static DWORD startUpProcess(const QString &iAppName);
    static HANDLE findWindowHandle(const QString & iClassName, const QString &iWindowName);
};

#endif // WIDGETCONTAINER_H
