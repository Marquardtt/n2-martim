SELECT p.nome_completo AS aluno, r.alternativa_escolhida, r.esta_correta FROM public.respostas r
JOIN public.sessoes_simulado ss ON ss.id = r.sessao_id
JOIN public.perfis p ON p.id = ss.aluno_id
JOIN public.questoes q ON q.id = r.questao_id
JOIN public.matriculas m ON m.aluno_id = ss.aluno_id
JOIN public.escolas e ON e.id = m.escola_id
WHERE q.numero_interno = 45 AND e.cnpj = '12345678000199';