#ifndef MAPUS_H
#define MAPUS_H

#include <QObject>
#include <QGeoRoute>
#include <QGeoRouteReply>
#include <QGeoRoutingManager>
#include <QGeoServiceProvider>
#include <QGeoCoordinate>
#include <QDebug>
#include <QNetworkAccessManager>
#include <QEventLoop>
#include <QNetworkReply>

class MapUs : public QObject
{
    Q_OBJECT

public:
    explicit MapUs(QObject *parent = nullptr);

public slots:
    void onButtonClicked(double start_Lat, double start_Long, double end_Lat, double end_Long);
    bool check_IP();

    QList <double> getDouble_lat();
    QList <double> getDouble_lng();
    int get_Size();
    QString get_Time();
    double get_Dist();

private:
    QList<QGeoCoordinate> coordinates;
    int time;
    double dist;
};

#endif // MAPUS_H
