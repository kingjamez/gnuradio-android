/********************
GNU Radio C++ Flow Graph Source File

Title: SignalLoopback
GNU Radio version: 3.10.3.0
********************/

#include "SignalLoopback.hpp"

using namespace gr;


SignalLoopback::SignalLoopback ()
: QWidget() {

    this->setWindowTitle("SignalLoopback");
    // check_set_qss
    // set icon
    this->top_scroll_layout = new QVBoxLayout();
    this->setLayout(this->top_scroll_layout);
    this->top_scroll = new QScrollArea();
    this->top_scroll->setFrameStyle(QFrame::NoFrame);
    this->top_scroll_layout->addWidget(this->top_scroll);
    this->top_scroll->setWidgetResizable(true);
    this->top_widget = new QWidget();
    this->top_scroll->setWidget(this->top_widget);
    this->top_layout = new QVBoxLayout(this->top_widget);
    this->top_grid_layout = new QGridLayout();
    this->top_layout->addLayout(this->top_grid_layout);

    this->settings = new QSettings("GNU Radio", "SignalLoopback");

    this->tb = gr::make_top_block("SignalLoopback");

// Blocks:
        qtgui_sink_x_0 = gr::qtgui::sink_c::make(
                1024, //fftsize
                fft::window::WIN_BLACKMAN_hARRIS, // wintype
                0, //fc
                samp_rate, //bw
                "", //name
                true, //plotfreq
                true, //plotwaterfall
                true, //plottime
                true //plotconst
            );
        qtgui_sink_x_0->set_update_time(1.0/10);
        qtgui_sink_x_0->enable_rf_freq(false);
        QWidget* _qtgui_sink_x_0_win;
        _qtgui_sink_x_0_win = this->qtgui_sink_x_0->qwidget();
        top_layout->addWidget(_qtgui_sink_x_0_win);

        this->analog_sig_source_x_0 = analog::sig_source_c::make(samp_rate, analog::GR_COS_WAVE, 1000, 1, 0,0);


// Connections:
    this->tb->hier_block2::connect(this->analog_sig_source_x_0, 0, this->qtgui_sink_x_0, 0);
}

SignalLoopback::~SignalLoopback () {
}

// Callbacks:
int SignalLoopback::get_samp_rate () const {
    return this->samp_rate;
}

void SignalLoopback::set_samp_rate (int samp_rate) {
    this->samp_rate = samp_rate;
    this->analog_sig_source_x_0->set_sampling_freq(this->samp_rate);
}


int main (int argc, char **argv) {

    QApplication app(argc, argv);

    SignalLoopback* top_block = new SignalLoopback();

    top_block->tb->start();
    top_block->show();
    app.exec();


    return 0;
}
#include "moc_SignalLoopback.cpp"
