#include "mdl.cuh"

void mdl_allez_retour(Mdl_t * mdl, BTCUSDT_t * btcusdt, uint * ts__d) {
	mdl_f (mdl, btcusdt, ts__d);
	//
	mdl_dy_zero(mdl);
	//
	df_btcusdt(
		btcusdt,
		mdl->inst[mdl->la_sortie]-> y__d,
		mdl->inst[mdl->la_sortie]->dy__d,
		ts__d
	);
	mdl_df(mdl, btcusdt, ts__d);
};