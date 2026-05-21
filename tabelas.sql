CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TYPE tipo_papel_usuario AS ENUM ('aluno', 'admin_escola', 'admin_global');
CREATE TYPE tipo_status_sessao AS ENUM ('em_andamento', 'concluida');

CREATE TABLE public.perfis (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    nome_completo TEXT NOT NULL,
    papel tipo_papel_usuario NOT NULL DEFAULT 'aluno',
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.perfis IS 'Perfis de todos os usuários da plataforma';
COMMENT ON COLUMN public.perfis.id IS 'Mesmo UUID do auth.users';
COMMENT ON COLUMN public.perfis.papel IS 'aluno | admin_escola | admin_global.';

CREATE TABLE public.escolas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome TEXT NOT NULL,
    cnpj CHAR(14) NOT NULL,
    admin_id UUID NOT NULL REFERENCES public.perfis(id),
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_escolas_cnpj UNIQUE (cnpj),
    CONSTRAINT chk_cnpj_digitos CHECK (cnpj ~ '^\d{14}$')
);

COMMENT ON TABLE  public.escolas IS 'Escolas cadastradas';
COMMENT ON COLUMN public.escolas.cnpj IS 'CNPJ sem pontuação';
COMMENT ON COLUMN public.escolas.admin_id IS 'Usuário admin_escola';

CREATE TABLE public.matriculas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    aluno_id UUID NOT NULL REFERENCES public.perfis(id) ON DELETE CASCADE,
    escola_id UUID NOT NULL REFERENCES public.escolas(id) ON DELETE CASCADE,
    matriculado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_matricula_por_escola UNIQUE (aluno_id, escola_id)
);

COMMENT ON TABLE public.matriculas IS 'Vínculo aluno-escola pra não deixar ter matrícula repetida';

CREATE TABLE public.questoes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    numero_interno INTEGER NOT NULL,
    enunciado JSONB NOT NULL,
    alternativas JSONB NOT NULL,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_questao_numero_interno UNIQUE (numero_interno),
    CONSTRAINT chk_numero_interno_positivo CHECK (numero_interno > 0)
);

COMMENT ON TABLE  public.questoes IS 'Questões';
COMMENT ON COLUMN public.questoes.enunciado IS 'Enunciado';
COMMENT ON COLUMN public.questoes.alternativas IS 'Array JSON';
COMMENT ON COLUMN public.questoes.numero_interno IS 'Numeração sequencial';

CREATE TABLE public.sessoes_simulado (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    aluno_id UUID NOT NULL REFERENCES public.perfis(id) ON DELETE CASCADE,
    iniciado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    finalizado_em TIMESTAMPTZ,
    status tipo_status_sessao NOT NULL DEFAULT 'em_andamento',
    total_questoes INTEGER NOT NULL DEFAULT 0,
    total_acertos INTEGER NOT NULL DEFAULT 0,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_finalizado_apos_iniciado
        CHECK (finalizado_em IS NULL OR finalizado_em >= iniciado_em),

    CONSTRAINT chk_acertos_menor_igual_total
        CHECK (total_acertos >= 0 AND total_acertos <= total_questoes),

    CONSTRAINT chk_total_questoes_nao_negativo
        CHECK (total_questoes >= 0)
);

COMMENT ON TABLE public.sessoes_simulado IS 'Sessões de simulado';
COMMENT ON COLUMN public.sessoes_simulado.total_questoes IS 'Contador';
COMMENT ON COLUMN public.sessoes_simulado.total_acertos IS 'Contador';

CREATE TABLE public.respostas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sessao_id UUID NOT NULL REFERENCES public.sessoes_simulado(id) ON DELETE CASCADE,
    questao_id UUID NOT NULL REFERENCES public.questoes(id) ON DELETE CASCADE,
    alternativa_escolhida INTEGER NOT NULL,
    esta_correta BOOLEAN NOT NULL,
    respondido_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_uma_resposta_por_questao_sessao
        UNIQUE (sessao_id, questao_id),

    CONSTRAINT chk_alternativa_escolhida_nao_negativa
        CHECK (alternativa_escolhida >= 0)
);

COMMENT ON TABLE  public.respostas IS 'Respostas dos alunos';
COMMENT ON COLUMN public.respostas.alternativa_escolhida IS 'Índice numérico';
COMMENT ON COLUMN public.respostas.questao_id IS 'Apaga respostas ao deletar questão';

CREATE INDEX idx_matriculas_aluno ON public.matriculas (aluno_id);
CREATE INDEX idx_matriculas_escola ON public.matriculas (escola_id);
CREATE INDEX idx_sessoes_aluno ON public.sessoes_simulado (aluno_id);
CREATE INDEX idx_sessoes_status ON public.sessoes_simulado (status);
CREATE INDEX idx_respostas_sessao ON public.respostas (sessao_id);
CREATE INDEX idx_respostas_questao ON public.respostas (questao_id);
CREATE INDEX idx_escolas_admin ON public.escolas (admin_id);