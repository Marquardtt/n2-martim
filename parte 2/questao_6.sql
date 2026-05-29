-- alterei manualmente pra constar algum retorno na query pois a trigger trg_atualizar_estatisticas_sessao 
-- atualiza p total_questoes e o total_acertos quando alguma resposta é colocada

UPDATE public.sessoes_simulado
SET total_questoes = 99, total_acertos = 99
WHERE id = '00000000-0000-0000-0004-000000000001';

SELECT
    ss.id AS sessao_id,
    ss.total_questoes AS total_questoes_armazenado,
    COUNT(r.id) AS contagem_real_respostas,
    ss.total_acertos AS total_acertos_armazenado,
    COUNT(r.id) FILTER (WHERE r.esta_correta = TRUE) AS contagem_real_acertos
FROM public.sessoes_simulado ss
LEFT JOIN public.respostas r ON r.sessao_id = ss.id
WHERE ss.status = 'concluida'
GROUP BY ss.id, ss.total_questoes, ss.total_acertos
HAVING ss.total_questoes <> COUNT(r.id) OR ss.total_acertos <> COUNT(r.id) FILTER (WHERE r.esta_correta = TRUE);