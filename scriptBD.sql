-- Adicionar Coluna na Tabela Accounts
ALTER TABLE accounts
ADD COLUMN limite_disparo INTEGER NOT NULL DEFAULT 100;

-- Adicionar Colunas na Tabela Campaigns
ALTER TABLE campaigns
ADD COLUMN status_envia INTEGER NOT NULL DEFAULT 0;
ALTER TABLE campaigns
ADD COLUMN enviou INTEGER NOT NULL DEFAULT 0;
ALTER TABLE campaigns
ADD COLUMN falhou INTEGER NOT NULL DEFAULT 0;

-- Cria a sequência
CREATE SEQUENCE campaigns_failled_id_seq;

-- Cria a tabela com a coluna `id` usando a sequência criada
CREATE TABLE campaigns_failled (
id BIGINT PRIMARY KEY NOT NULL DEFAULT nextval('campaigns_failled_id_seq'::regclass),
nomecontato TEXT NOT NULL,
telefone CHARACTER VARYING NOT NULL,
id_campanha INTEGER NOT NULL
);

-- Função para replicar inserções
CREATE OR REPLACE FUNCTION replicate_labels_to_tags()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO tags (id, name)
    VALUES (NEW.id, NEW.title);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--Função para replicar exclusões
CREATE OR REPLACE FUNCTION delete_labels_from_tags_and_taggings()
RETURNS TRIGGER AS $$
BEGIN
    -- Exclui da tabela tags
    DELETE FROM tags WHERE id = OLD.id;
    -- Exclui da tabela taggings
    DELETE FROM taggings WHERE tag_id = OLD.id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Função para replicar atualizações
CREATE OR REPLACE FUNCTION update_labels_to_tags()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE tags
    SET name = NEW.title
    WHERE id = NEW.id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para inserções
CREATE TRIGGER after_insert_labels
AFTER INSERT ON labels
FOR EACH ROW
EXECUTE FUNCTION replicate_labels_to_tags();

-- Trigger para exclusões
CREATE TRIGGER after_delete_labels
AFTER DELETE ON labels
FOR EACH ROW
EXECUTE FUNCTION delete_labels_from_tags_and_taggings();

-- Trigger para atualizações
CREATE TRIGGER after_update_labels
AFTER UPDATE ON labels
FOR EACH ROW
EXECUTE FUNCTION update_labels_to_tags();