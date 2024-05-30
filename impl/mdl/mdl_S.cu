#include "mdl.cuh"

float mdl_S(Mdl_t * mdl, BTCUSDT_t * btcusdt, uint * ts__d) {
	mdl_f(mdl, btcusdt, ts__d);
	return f_btcusdt(btcusdt, mdl->inst[mdl->la_sortie]->y__d, ts__d);
};