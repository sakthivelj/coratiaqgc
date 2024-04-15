#include "widgetanchor.h"
#include <QQuickItem>

WidgetAnchor::WidgetAnchor(QWidget *pWidget, QQuickItem *pItem)
    : QObject(pWidget),
    _pWidget(pWidget),
    _pQuickItem(pItem)
{
    connect(_pQuickItem, &QQuickItem::xChanged, this, &WidgetAnchor::updateGeometry);
    connect(_pQuickItem, &QQuickItem::yChanged, this, &WidgetAnchor::updateGeometry);
    connect(_pQuickItem, &QQuickItem::widthChanged, this, &WidgetAnchor::updateGeometry);
    connect(_pQuickItem, &QQuickItem::heightChanged, this, &WidgetAnchor::updateGeometry);
    updateGeometry();
}

void WidgetAnchor::updateGeometry(){
    if (_pQuickItem) {
        QRectF r = _pQuickItem->mapRectToItem(nullptr, QRectF(_pQuickItem->x() + 5, _pQuickItem->y() + 5, _pQuickItem->width() * 1.05 , _pQuickItem->height() * 1.15));
        _pWidget->setGeometry(r.toRect());
    }
}
