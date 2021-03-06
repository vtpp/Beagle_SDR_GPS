/*
--------------------------------------------------------------------------------
This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Library General Public
License as published by the Free Software Foundation; either
version 2 of the License, or (at your option) any later version.
This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Library General Public License for more details.
You should have received a copy of the GNU Library General Public
License along with this library; if not, write to the
Free Software Foundation, Inc., 51 Franklin St, Fifth Floor,
Boston, MA  02110-1301, USA.
--------------------------------------------------------------------------------
*/

// Copyright (c) 2015 John Seamons, ZL/KF6VO

#ifndef _DATA_PUMP_H_
#define _DATA_PUMP_H_

#include "types.h"
#include "spi.h"
#include "cuteSDR.h"
#include "ima_adpcm.h"

#include <fftw3.h>

#ifdef USE_WF_NEW
#define	WF_USING_HALF_FFT	1	// the result is contained in the first half of the complex FFT
#define	WF_USING_HALF_CIC	1	// only use half of the remaining FFT after a CIC
#define	WF_BETTER_LOOKING	1	// increase in FFT size for better looking display
#else
#define	WF_USING_HALF_FFT	2	// the result is contained in the first half of the complex FFT
#define	WF_USING_HALF_CIC	2	// only use half of the remaining FFT after a CIC
#define	WF_BETTER_LOOKING	2	// increase in FFT size for better looking display
#endif

#define	WF_WIDTH	1024	// width of waterfall display
#define WF_OUTPUT	1024	// conceptually same as WF_WIDTH although not required
#define WF_C_NFFT	(WF_OUTPUT * WF_USING_HALF_FFT * WF_USING_HALF_CIC * WF_BETTER_LOOKING)	// worst case FFT size needed
#define WF_C_NSAMPS	WF_C_NFFT
#define WF_N_CHUNKS	(WF_C_NSAMPS / NWF_SAMPS)

struct rx_iq_t {
	u2_t i, q;
	u1_t q3, i3;	// NB: endian swap
} __attribute__((packed));
			
struct wf_iq_t {
	u2_t i, q;
} __attribute__((packed));

#define N_DPBUF	16

#define	SBUF_FIR	0
#define	SBUF_AGC	1
#define	SBUF_N		2
#define SBUF_SLOP	512

struct rx_dpump_t {
	struct {
		u4_t wr_pos, rd_pos;
		TYPECPX in_samps[N_DPBUF][FASTFIR_OUTBUF_SIZE + SBUF_SLOP];
		TYPECPX cpx_samples[SBUF_N][FASTFIR_OUTBUF_SIZE + SBUF_SLOP];
		TYPEREAL real_samples[FASTFIR_OUTBUF_SIZE + SBUF_SLOP];
		TYPEMONO16 mono16_samples[FASTFIR_OUTBUF_SIZE + SBUF_SLOP];
	};
	struct {
		u64_t gen, proc;
		SPI_MISO wf_miso[2];			// ping-pong buffers for pipelining
		fftwf_complex *wf_c_samps;
		u4_t desired;
		float chunk_wait_us;
		int zoom, samp_wait_ms;
		bool overlapped_sampling;
		ima_adpcm_state_t adpcm_snd;
	};
};

extern rx_dpump_t rx_dpump[RX_CHANS];
extern float wf_window_function_c[WF_C_NSAMPS];

#define	RXOUT_SCALE	(RXO_BITS-1)	// s24 -> +/- 1.0
#define	CUTESDR_SCALE	15			// +/- 1.0 -> +/- 32.0K (s16 equivalent)

enum rx_chan_action_e {RX_CHAN_ENABLE, RX_CHAN_DISABLE, RX_CHAN_FREE };
	
void data_pump_init();
void rx_enable(int chan, rx_chan_action_e action);

#endif
