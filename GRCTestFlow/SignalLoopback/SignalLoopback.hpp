#ifndef SIGNALLOOPBACK_HPP
#define SIGNALLOOPBACK_HPP
/********************
GNU Radio C++ Flow Graph Header File

Title: SignalLoopback
GNU Radio version: 3.10.3.0
********************/

/********************
** Create includes
********************/
#include <gnuradio/top_block.h>
#include <gnuradio/analog/sig_source.h>
#include <gnuradio/qtgui/sink_c.h>
#include <gnuradio/filter/firdes.h>

#include <QVBoxLayout>
#include <QScrollArea>
#include <QWidget>
#include <QGridLayout>
#include <QSettings>
#include <QApplication>


using namespace gr;



class SignalLoopback : public QWidget {
    Q_OBJECT

private:
    QVBoxLayout *top_scroll_layout;
    QScrollArea *top_scroll;
    QWidget *top_widget;
    QVBoxLayout *top_layout;
    QGridLayout *top_grid_layout;
    QSettings *settings;


    gr::qtgui::sink_c::sptr qtgui_sink_x_0;
    analog::sig_source_c::sptr analog_sig_source_x_0;


// Variables:
    int samp_rate = 32000;

public:
    top_block_sptr tb;
    SignalLoopback();
    ~SignalLoopback();

    int get_samp_rate () const;
    void set_samp_rate(int samp_rate);

};


#endif

