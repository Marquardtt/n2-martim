SELECT p.nome_completo AS aluno, 
       SUM(ss.total_acertos) AS total_acertos,
       SUM(ss.total_questoes) AS total_questoes
FROM public.perfis p
JOIN public.sessoes_simulado ss ON ss.aluno_id = p.id
WHERE p.papel= 'aluno' AND ss.status = 'concluida'
GROUP BY p.id, p.nome_completo
HAVING SUM(ss.total_questoes) >= 1 -- alterei pra conseguir retornar alguma informação
ORDER BY total_acertos DESC
LIMIT 5;

--retornou 99 pra karen por conta do update na query 6