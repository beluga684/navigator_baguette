#include "mapus.h"

MapUs::MapUs(QObject *parent) : QObject(parent) //конструктор
{

}

void MapUs::onButtonClicked(double start_Lat, double start_Long, double end_Lat, double end_Long) //расчёт точек маршрута
{
    coordinates.clear();

    if (qIsNaN(start_Lat) or qIsNaN(start_Long) or qIsNaN(end_Lat) or qIsNaN(end_Long))
    {
        qDebug() << "кривое значение детектед!";
        return;
    }

    QGeoServiceProvider *serviceProvider = new QGeoServiceProvider("osm");
    QGeoRoutingManager *routingManager = serviceProvider->routingManager();

    QGeoCoordinate startPoint(start_Lat, start_Long);
    QGeoCoordinate endPoint(end_Lat, end_Long);

    QGeoRouteRequest request(startPoint, endPoint);
    QGeoRouteReply *reply = routingManager->calculateRoute(request);

    qDebug() << "ща посчитаю";

    QObject::connect(reply, &QGeoRouteReply::finished, [=]()
    {
        if (reply->error() == QGeoRouteReply::NoError)
        {
            QList<QGeoRoute> routes = reply->routes();
            for (const QGeoRoute &route : qAsConst(routes))
            {
                qDebug() << "Distance:" << route.distance() << "метров";
                qDebug() << "Travel time:" << route.travelTime() << "секунд";
                time = route.travelTime();
                dist = route.distance();
                coordinates = route.path();
                for (const QGeoCoordinate &coordinate : qAsConst(coordinates))
                {
                    qDebug() << "Coordinate:" << coordinate;
                }
            }
            qDebug() << "посчитал";
        }
        else
        {
            qDebug() << "Error:" << reply->errorString();
        }
        reply->deleteLater();
    });
}

bool MapUs::check_IP() //функция проверки подключения к wi-fi
{
    QNetworkAccessManager nam;
    QNetworkRequest req(QUrl("http://www.google.com"));
    QNetworkReply *reply = nam.get(req);
    QEventLoop loop;
    connect(reply, SIGNAL(finished()), &loop, SLOT(quit()));
    loop.exec();
    if(reply->bytesAvailable())
        return true;
    else
        return false;
}

QList<double> MapUs::getDouble_lng() //передача значений долготы
{
    QList <double> doubleList;
    for (int i = 0; i < coordinates.size(); i++)
    {
        doubleList.append(coordinates[i].longitude());
    }
    return doubleList;
}

QList<double> MapUs::getDouble_lat() //передача значений широты
{
    QList <double> doubleList;
    for (int i = 0; i < coordinates.size(); i++)
    {
        doubleList.append(coordinates[i].latitude());
    }
    return doubleList;
}

int MapUs::get_Size() //передача размера массива координат
{
    return coordinates.size();
}

QString MapUs::get_Time() //передача времени пути
{
    int seconds, secs, minutes, hours;

    seconds = time;

    hours = seconds / 3600;
    seconds %= 3600;
    minutes = seconds / 60;
    secs = seconds % 60;

    return (QString::number(hours) + " часов " + QString::number(minutes) + " минут " + QString::number(secs) + " секунд");
}

double MapUs::get_Dist() //передача расстояния пути
{
    return dist;
}
