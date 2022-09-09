#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#
# SPDX-License-Identifier: GPL-3.0
#
# GNU Radio Python Flow Graph
# Title: FMRecv
# GNU Radio version: 3.10.3.0

from packaging.version import Version as StrictVersion

if __name__ == '__main__':
    import ctypes
    import sys
    if sys.platform.startswith('linux'):
        try:
            x11 = ctypes.cdll.LoadLibrary('libX11.so')
            x11.XInitThreads()
        except:
            print("Warning: failed to XInitThreads()")

from PyQt5 import Qt
from gnuradio import qtgui
from gnuradio.filter import firdes
import sip
from gnuradio import analog
from gnuradio import audio
from gnuradio import blocks
from gnuradio import filter
from gnuradio import gr
from gnuradio.fft import window
import sys
import signal
from argparse import ArgumentParser
from gnuradio.eng_arg import eng_float, intx
from gnuradio import eng_notation
from gnuradio import iio
from gnuradio.qtgui import Range, GrRangeWidget
from PyQt5 import QtCore



from gnuradio import qtgui

class FMRecv(gr.top_block, Qt.QWidget):

    def __init__(self):
        gr.top_block.__init__(self, "FMRecv", catch_exceptions=True)
        Qt.QWidget.__init__(self)
        self.setWindowTitle("FMRecv")
        qtgui.util.check_set_qss()
        try:
            self.setWindowIcon(Qt.QIcon.fromTheme('gnuradio-grc'))
        except:
            pass
        self.top_scroll_layout = Qt.QVBoxLayout()
        self.setLayout(self.top_scroll_layout)
        self.top_scroll = Qt.QScrollArea()
        self.top_scroll.setFrameStyle(Qt.QFrame.NoFrame)
        self.top_scroll_layout.addWidget(self.top_scroll)
        self.top_scroll.setWidgetResizable(True)
        self.top_widget = Qt.QWidget()
        self.top_scroll.setWidget(self.top_widget)
        self.top_layout = Qt.QVBoxLayout(self.top_widget)
        self.top_grid_layout = Qt.QGridLayout()
        self.top_layout.addLayout(self.top_grid_layout)

        self.settings = Qt.QSettings("GNU Radio", "FMRecv")

        try:
            if StrictVersion(Qt.qVersion()) < StrictVersion("5.0.0"):
                self.restoreGeometry(self.settings.value("geometry").toByteArray())
            else:
                self.restoreGeometry(self.settings.value("geometry"))
        except:
            pass

        ##################################################
        # Variables
        ##################################################
        self.volume = volume = 0.1
        self.sample_rate_tx = sample_rate_tx = 128000
        self.sample_rate_rx = sample_rate_rx = 128000
        self.quad_rate_tx = quad_rate_tx = 128000
        self.quad_rate_rx = quad_rate_rx = 128000
        self.grflowrun_uri = grflowrun_uri = "ip:192.168.0.200"
        self.audio_out_rate = audio_out_rate = 16000
        self.audio_in_rate = audio_in_rate = 16000
        self.PTT = PTT = 89
        self.LO = LO = 462562500

        ##################################################
        # Blocks
        ##################################################
        self._volume_range = Range(0, 1, 0.05, 0.1, 200)
        self._volume_win = GrRangeWidget(self._volume_range, self.set_volume, "volume", "slider", float, QtCore.Qt.Horizontal, "value")
        self.volume = self._volume_win

        self.top_grid_layout.addWidget(self._volume_win, 0, 0, 1, 1)
        for r in range(0, 1):
            self.top_grid_layout.setRowStretch(r, 1)
        for c in range(0, 1):
            self.top_grid_layout.setColumnStretch(c, 1)
        _PTT_push_button = Qt.QPushButton('PTT')
        _PTT_push_button = Qt.QPushButton('PTT')
        self._PTT_choices = {'Pressed': 0, 'Released': 89}
        _PTT_push_button.pressed.connect(lambda: self.set_PTT(self._PTT_choices['Pressed']))
        _PTT_push_button.released.connect(lambda: self.set_PTT(self._PTT_choices['Released']))
        self.top_grid_layout.addWidget(_PTT_push_button, 0, 1, 2, 1)
        for r in range(0, 2):
            self.top_grid_layout.setRowStretch(r, 1)
        for c in range(1, 2):
            self.top_grid_layout.setColumnStretch(c, 1)
        self._LO_range = Range(70000000, 6000000000, 1, 462562500, 200)
        self._LO_win = GrRangeWidget(self._LO_range, self.set_LO, "LO Frequency", "counter", float, QtCore.Qt.Horizontal, "value")
        self.LO = self._LO_win

        self.top_grid_layout.addWidget(self._LO_win, 1, 0, 1, 1)
        for r in range(1, 2):
            self.top_grid_layout.setRowStretch(r, 1)
        for c in range(0, 1):
            self.top_grid_layout.setColumnStretch(c, 1)
        self.rational_resampler_xxx_0 = filter.rational_resampler_ccc(
                interpolation=(int(sample_rate_tx/quad_rate_tx)),
                decimation=1,
                taps=[],
                fractional_bw=0)
        self.qtgui_time_sink_x_0 = qtgui.time_sink_f(
            1024, #size
            audio_out_rate, #samp_rate
            'Audio', #name
            1, #number of inputs
            None # parent
        )
        self.qtgui_time_sink_x_0.set_update_time(0.10)
        self.qtgui_time_sink_x_0.set_y_axis(-1, 1)

        self.qtgui_time_sink_x_0.set_y_label('Amplitude', "")

        self.qtgui_time_sink_x_0.enable_tags(True)
        self.qtgui_time_sink_x_0.set_trigger_mode(qtgui.TRIG_MODE_FREE, qtgui.TRIG_SLOPE_POS, 0.0, 0, 0, "")
        self.qtgui_time_sink_x_0.enable_autoscale(False)
        self.qtgui_time_sink_x_0.enable_grid(False)
        self.qtgui_time_sink_x_0.enable_axis_labels(True)
        self.qtgui_time_sink_x_0.enable_control_panel(False)
        self.qtgui_time_sink_x_0.enable_stem_plot(False)


        labels = ['Signal 1', 'Signal 2', 'Signal 3', 'Signal 4', 'Signal 5',
            'Signal 6', 'Signal 7', 'Signal 8', 'Signal 9', 'Signal 10']
        widths = [1, 1, 1, 1, 1,
            1, 1, 1, 1, 1]
        colors = ['blue', 'red', 'green', 'black', 'cyan',
            'magenta', 'yellow', 'dark red', 'dark green', 'dark blue']
        alphas = [1.0, 1.0, 1.0, 1.0, 1.0,
            1.0, 1.0, 1.0, 1.0, 1.0]
        styles = [1, 1, 1, 1, 1,
            1, 1, 1, 1, 1]
        markers = [-1, -1, -1, -1, -1,
            -1, -1, -1, -1, -1]


        for i in range(1):
            if len(labels[i]) == 0:
                self.qtgui_time_sink_x_0.set_line_label(i, "Data {0}".format(i))
            else:
                self.qtgui_time_sink_x_0.set_line_label(i, labels[i])
            self.qtgui_time_sink_x_0.set_line_width(i, widths[i])
            self.qtgui_time_sink_x_0.set_line_color(i, colors[i])
            self.qtgui_time_sink_x_0.set_line_style(i, styles[i])
            self.qtgui_time_sink_x_0.set_line_marker(i, markers[i])
            self.qtgui_time_sink_x_0.set_line_alpha(i, alphas[i])

        self._qtgui_time_sink_x_0_win = sip.wrapinstance(self.qtgui_time_sink_x_0.qwidget(), Qt.QWidget)
        self.top_layout.addWidget(self._qtgui_time_sink_x_0_win)
        self.qtgui_sink_x_2 = qtgui.sink_c(
            1024, #fftsize
            window.WIN_BLACKMAN_hARRIS, #wintype
            0, #fc
            576000, #bw
            'RF Out', #name
            True, #plotfreq
            True, #plotwaterfall
            True, #plottime
            True, #plotconst
            None # parent
        )
        self.qtgui_sink_x_2.set_update_time(1.0/10)
        self._qtgui_sink_x_2_win = sip.wrapinstance(self.qtgui_sink_x_2.qwidget(), Qt.QWidget)

        self.qtgui_sink_x_2.enable_rf_freq(False)

        self.top_grid_layout.addWidget(self._qtgui_sink_x_2_win, 3, 0, 1, 1)
        for r in range(3, 4):
            self.top_grid_layout.setRowStretch(r, 1)
        for c in range(0, 1):
            self.top_grid_layout.setColumnStretch(c, 1)
        self.qtgui_sink_x_1 = qtgui.sink_c(
            1024, #fftsize
            window.WIN_BLACKMAN_hARRIS, #wintype
            0, #fc
            sample_rate_rx, #bw
            'RF In', #name
            True, #plotfreq
            True, #plotwaterfall
            True, #plottime
            True, #plotconst
            None # parent
        )
        self.qtgui_sink_x_1.set_update_time(1.0/10)
        self._qtgui_sink_x_1_win = sip.wrapinstance(self.qtgui_sink_x_1.qwidget(), Qt.QWidget)

        self.qtgui_sink_x_1.enable_rf_freq(False)

        self.top_grid_layout.addWidget(self._qtgui_sink_x_1_win, 3, 1, 1, 1)
        for r in range(3, 4):
            self.top_grid_layout.setRowStretch(r, 1)
        for c in range(1, 2):
            self.top_grid_layout.setColumnStretch(c, 1)
        self.low_pass_filter_1 = filter.fir_filter_ccf(
            1,
            firdes.low_pass(
                1,
                quad_rate_tx,
                5000,
                2000,
                window.WIN_HAMMING,
                6.76))
        self.low_pass_filter_0 = filter.fir_filter_ccf(
            ((int)(sample_rate_rx / (quad_rate_rx))),
            firdes.low_pass(
                1,
                sample_rate_rx ,
                5000,
                2000,
                window.WIN_HAMMING,
                6.76))
        self.iio_pluto_source_0 = iio.fmcomms2_source_fc32(grflowrun_uri if grflowrun_uri else iio.get_pluto_uri(), [True, True], (16*1024))
        self.iio_pluto_source_0.set_len_tag_key('packet_len')
        self.iio_pluto_source_0.set_frequency(LO)
        self.iio_pluto_source_0.set_samplerate(sample_rate_rx)
        self.iio_pluto_source_0.set_gain_mode(0, 'fast_attack')
        self.iio_pluto_source_0.set_gain(0, 64)
        self.iio_pluto_source_0.set_quadrature(True)
        self.iio_pluto_source_0.set_rfdc(True)
        self.iio_pluto_source_0.set_bbdc(True)
        self.iio_pluto_source_0.set_filter_params('Auto', '', 0, 0)
        self.iio_pluto_sink_0 = iio.fmcomms2_sink_fc32(grflowrun_uri if grflowrun_uri else iio.get_pluto_uri(), [True, True], 16384, False)
        self.iio_pluto_sink_0.set_len_tag_key('')
        self.iio_pluto_sink_0.set_bandwidth(200000)
        self.iio_pluto_sink_0.set_frequency(LO)
        self.iio_pluto_sink_0.set_samplerate(sample_rate_tx)
        self.iio_pluto_sink_0.set_attenuation(0, PTT)
        self.iio_pluto_sink_0.set_filter_params('Auto', '', 0, 0)
        self.dc_blocker_xx_0 = filter.dc_blocker_ff(32, True)
        self.blocks_multiply_const_vxx_0 = blocks.multiply_const_ff(volume)
        self.blocks_copy_1 = blocks.copy(gr.sizeof_gr_complex*1)
        self.blocks_copy_1.set_enabled(PTT)
        self.blocks_copy_0 = blocks.copy(gr.sizeof_float*1)
        self.blocks_copy_0.set_enabled(not PTT)
        self.audio_source_0 = audio.source(audio_in_rate, '', True)
        self.audio_sink_0 = audio.sink(audio_out_rate, '', True)
        self.analog_nbfm_tx_0 = analog.nbfm_tx(
        	audio_rate=audio_in_rate,
        	quad_rate=quad_rate_tx,
        	tau=(75e-6),
        	max_dev=5e3,
        	fh=(-1.0),
                )
        self.analog_nbfm_rx_0 = analog.nbfm_rx(
        	audio_rate=audio_out_rate,
        	quad_rate=quad_rate_rx,
        	tau=(75e-6),
        	max_dev=5e3,
          )


        ##################################################
        # Connections
        ##################################################
        self.connect((self.analog_nbfm_rx_0, 0), (self.dc_blocker_xx_0, 0))
        self.connect((self.analog_nbfm_tx_0, 0), (self.low_pass_filter_1, 0))
        self.connect((self.audio_source_0, 0), (self.blocks_copy_0, 0))
        self.connect((self.blocks_copy_0, 0), (self.analog_nbfm_tx_0, 0))
        self.connect((self.blocks_copy_1, 0), (self.low_pass_filter_0, 0))
        self.connect((self.blocks_multiply_const_vxx_0, 0), (self.audio_sink_0, 0))
        self.connect((self.blocks_multiply_const_vxx_0, 0), (self.qtgui_time_sink_x_0, 0))
        self.connect((self.dc_blocker_xx_0, 0), (self.blocks_multiply_const_vxx_0, 0))
        self.connect((self.iio_pluto_source_0, 0), (self.blocks_copy_1, 0))
        self.connect((self.low_pass_filter_0, 0), (self.analog_nbfm_rx_0, 0))
        self.connect((self.low_pass_filter_0, 0), (self.qtgui_sink_x_1, 0))
        self.connect((self.low_pass_filter_1, 0), (self.rational_resampler_xxx_0, 0))
        self.connect((self.rational_resampler_xxx_0, 0), (self.iio_pluto_sink_0, 0))
        self.connect((self.rational_resampler_xxx_0, 0), (self.qtgui_sink_x_2, 0))


    def closeEvent(self, event):
        self.settings = Qt.QSettings("GNU Radio", "FMRecv")
        self.settings.setValue("geometry", self.saveGeometry())
        self.stop()
        self.wait()

        event.accept()

    def get_volume(self):
        return self.volume

    def set_volume(self, volume):
        self.volume = volume
        self.blocks_multiply_const_vxx_0.set_k(self.volume)

    def get_sample_rate_tx(self):
        return self.sample_rate_tx

    def set_sample_rate_tx(self, sample_rate_tx):
        self.sample_rate_tx = sample_rate_tx
        self.iio_pluto_sink_0.set_samplerate(self.sample_rate_tx)

    def get_sample_rate_rx(self):
        return self.sample_rate_rx

    def set_sample_rate_rx(self, sample_rate_rx):
        self.sample_rate_rx = sample_rate_rx
        self.iio_pluto_source_0.set_samplerate(self.sample_rate_rx)
        self.low_pass_filter_0.set_taps(firdes.low_pass(1, self.sample_rate_rx , 5000, 2000, window.WIN_HAMMING, 6.76))
        self.qtgui_sink_x_1.set_frequency_range(0, self.sample_rate_rx)

    def get_quad_rate_tx(self):
        return self.quad_rate_tx

    def set_quad_rate_tx(self, quad_rate_tx):
        self.quad_rate_tx = quad_rate_tx
        self.low_pass_filter_1.set_taps(firdes.low_pass(1, self.quad_rate_tx, 5000, 2000, window.WIN_HAMMING, 6.76))

    def get_quad_rate_rx(self):
        return self.quad_rate_rx

    def set_quad_rate_rx(self, quad_rate_rx):
        self.quad_rate_rx = quad_rate_rx

    def get_grflowrun_uri(self):
        return self.grflowrun_uri

    def set_grflowrun_uri(self, grflowrun_uri):
        self.grflowrun_uri = grflowrun_uri

    def get_audio_out_rate(self):
        return self.audio_out_rate

    def set_audio_out_rate(self, audio_out_rate):
        self.audio_out_rate = audio_out_rate
        self.qtgui_time_sink_x_0.set_samp_rate(self.audio_out_rate)

    def get_audio_in_rate(self):
        return self.audio_in_rate

    def set_audio_in_rate(self, audio_in_rate):
        self.audio_in_rate = audio_in_rate

    def get_PTT(self):
        return self.PTT

    def set_PTT(self, PTT):
        self.PTT = PTT
        self.blocks_copy_0.set_enabled(not self.PTT)
        self.blocks_copy_1.set_enabled(self.PTT)
        self.iio_pluto_sink_0.set_attenuation(0,self.PTT)

    def get_LO(self):
        return self.LO

    def set_LO(self, LO):
        self.LO = LO
        self.iio_pluto_sink_0.set_frequency(self.LO)
        self.iio_pluto_source_0.set_frequency(self.LO)




def main(top_block_cls=FMRecv, options=None):

    if StrictVersion("4.5.0") <= StrictVersion(Qt.qVersion()) < StrictVersion("5.0.0"):
        style = gr.prefs().get_string('qtgui', 'style', 'raster')
        Qt.QApplication.setGraphicsSystem(style)
    qapp = Qt.QApplication(sys.argv)

    tb = top_block_cls()

    tb.start()

    tb.show()

    def sig_handler(sig=None, frame=None):
        tb.stop()
        tb.wait()

        Qt.QApplication.quit()

    signal.signal(signal.SIGINT, sig_handler)
    signal.signal(signal.SIGTERM, sig_handler)

    timer = Qt.QTimer()
    timer.start(500)
    timer.timeout.connect(lambda: None)

    qapp.exec_()

if __name__ == '__main__':
    main()
