#ifndef WIDGETANCHOR_H
#define WIDGETANCHOR_H

#include <QQuickItem>
#include <QObject>
#include <QWindow>

class WidgetAnchor : public QObject
{
    Q_OBJECT
public:
    WidgetAnchor(QWidget *pWidget, QQuickItem *pItem);
    void updateGeometry();

private:
    QWidget *_pWidget;
    QQuickItem *_pQuickItem;
};

#endif // WIDGETANCHOR_H
