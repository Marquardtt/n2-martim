INSERT INTO auth.users (id, email, created_at, updated_at, raw_user_meta_data)
VALUES
    ('00000000-0000-0000-0000-000000000001', 'marquardt@email.com', NOW(), NOW(), '{"nome_completo": "Marquardt adm global",   "papel": "admin_global"}'),
    ('00000000-0000-0000-0000-000000000002', 'kauan@email.com',     NOW(), NOW(), '{"nome_completo": "Kauan adm Gertrudes",    "papel": "admin_escola"}'),
    ('00000000-0000-0000-0000-000000000003', 'esther@email.com',    NOW(), NOW(), '{"nome_completo": "Esther adm Ayroso",      "papel": "admin_escola"}'),
    ('00000000-0000-0000-0000-000000000004', 'karen@email.com',     NOW(), NOW(), '{"nome_completo": "Karen da Silva Amancio", "papel": "aluno"}'),
    ('00000000-0000-0000-0000-000000000005', 'felipe.t@email.com',  NOW(), NOW(), '{"nome_completo": "Felipe Tomio Maciel",    "papel": "aluno"}'),
    ('00000000-0000-0000-0000-000000000006', 'igor@email.com',      NOW(), NOW(), '{"nome_completo": "Igor Gorges",            "papel": "aluno"}'),
    ('00000000-0000-0000-0000-000000000007', 'deretti@email.com',   NOW(), NOW(), '{"nome_completo": "Felipe Deretti",         "papel": "aluno"}'),
    ('00000000-0000-0000-0000-000000000008', 'matheus@email.com',   NOW(), NOW(), '{"nome_completo": "Matheus Wroblevski",     "papel": "aluno"}');

INSERT INTO public.escolas (id, nome, cnpj, admin_id) VALUES
    ('00000000-0000-0000-0001-000000000001', 'Getrudes Steilen Milbratz', '12345678000199', '00000000-0000-0000-0000-000000000002'),
    ('00000000-0000-0000-0001-000000000002', 'Lilia Ayroso Oechsler',     '83784991000178', '00000000-0000-0000-0000-000000000003');

INSERT INTO public.matriculas (id, aluno_id, escola_id) VALUES
    ('00000000-0000-0000-0002-000000000001', '00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0001-000000000001'),
    ('00000000-0000-0000-0002-000000000002', '00000000-0000-0000-0000-000000000005', '00000000-0000-0000-0001-000000000001'),
    ('00000000-0000-0000-0002-000000000003', '00000000-0000-0000-0000-000000000006', '00000000-0000-0000-0001-000000000001'),
    ('00000000-0000-0000-0002-000000000004', '00000000-0000-0000-0000-000000000007', '00000000-0000-0000-0001-000000000002'),
    ('00000000-0000-0000-0002-000000000005', '00000000-0000-0000-0000-000000000008', '00000000-0000-0000-0001-000000000002');

INSERT INTO public.questoes (id, numero_interno, enunciado, alternativas) VALUES
    ('00000000-0000-0000-0003-000000000001', 1,
        '{"texto": "Quanto é 2 + 2?"}',
        '[{"indice": 0, "texto": "3"}, {"indice": 1, "texto": "4"}, {"indice": 2, "texto": "5"}]'),
    ('00000000-0000-0000-0003-000000000002', 2,
        '{"texto": "Qual a capital do Brasil?"}',
        '[{"indice": 0, "texto": "São Paulo"}, {"indice": 1, "texto": "Brasília"}, {"indice": 2, "texto": "Rio de Janeiro"}]'),
    ('00000000-0000-0000-0003-000000000045', 45,
        '{"texto": "Questão de número 45?"}',
        '[{"indice": 0, "texto": "Opção A"}, {"indice": 1, "texto": "Opção B"}, {"indice": 2, "texto": "Opção C"}]');

INSERT INTO public.sessoes_simulado (id, aluno_id, finalizado_em, status, total_questoes, total_acertos) VALUES
    ('00000000-0000-0000-0004-000000000001', '00000000-0000-0000-0000-000000000004', NULL, 'em_andamento', 0, 0),
    ('00000000-0000-0000-0004-000000000002', '00000000-0000-0000-0000-000000000005', NULL, 'em_andamento', 0, 0),
    ('00000000-0000-0000-0004-000000000003', '00000000-0000-0000-0000-000000000006', NULL, 'em_andamento', 0, 0);

INSERT INTO public.respostas (id, sessao_id, questao_id, alternativa_escolhida, esta_correta) VALUES
    ('00000000-0000-0000-0005-000000000001', '00000000-0000-0000-0004-000000000001', '00000000-0000-0000-0003-000000000001', 1, TRUE),
    ('00000000-0000-0000-0005-000000000002', '00000000-0000-0000-0004-000000000001', '00000000-0000-0000-0003-000000000045', 0, FALSE),
    ('00000000-0000-0000-0005-000000000003', '00000000-0000-0000-0004-000000000002', '00000000-0000-0000-0003-000000000045', 1, TRUE);

UPDATE public.sessoes_simulado
SET status = 'concluida', finalizado_em = NOW()
WHERE id IN (
    '00000000-0000-0000-0004-000000000001',
    '00000000-0000-0000-0004-000000000002'
);