#include "mdl.cuh"

#include "../../impl_template/tmpl_etc.cu"

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

float* mdl_allez_retour_temps(Mdl_t * mdl, BTCUSDT_t * btcusdt, uint * ts__d)
{
	float * t_f = mdl_f__temps(mdl, btcusdt, ts__d);
	//
	mdl_dy_zero(mdl);
	//
	df_btcusdt(
		btcusdt,
		mdl->inst[mdl->la_sortie]-> y__d,
		mdl->inst[mdl->la_sortie]->dy__d,
		ts__d
	);
	float * t_df = mdl_df_temps(mdl, btcusdt, ts__d);
	//
	float * t = alloc<float>(2 * mdl->BLOQUES);
	memcpy(t, t_f, sizeof(float) * mdl->BLOQUES);
	memcpy(t+mdl->BLOQUES, t_df, sizeof(float) * mdl->BLOQUES);
	//
	free(t_f);
	free(t_df);
	//
	return t;
};