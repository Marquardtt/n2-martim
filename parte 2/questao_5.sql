SELECT e.nome AS escola,
    ROUND(
        SUM(ss.total_acertos)::NUMERIC
        / NULLIF(SUM(ss.total_questoes), 0) * 100,
        2
    ) AS percentual_acerto
FROM public.escolas e
JOIN public.matriculas m ON m.escola_id = e.id
JOIN public.sessoes_simulado ss ON ss.aluno_id = m.aluno_id
WHERE ss.status = 'concluida' GROUP BY e.id, e.nome
ORDER BY percentual_acerto DESC;