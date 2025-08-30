-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 30/08/2025 às 11:30
-- Versão do servidor: 10.4.32-MariaDB
-- Versão do PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `wkdatabase`
--

-- --------------------------------------------------------

--
-- Estrutura para tabela `cliente`
--

CREATE TABLE `cliente` (
  `id_cliente` int(11) NOT NULL,
  `nome` varchar(80) NOT NULL,
  `cidade` varchar(80) NOT NULL,
  `uf` char(2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Despejando dados para a tabela `cliente`
--

INSERT INTO `cliente` (`id_cliente`, `nome`, `cidade`, `uf`) VALUES
(1, 'Ana Beatriz', 'São Paulo', 'SP'),
(2, 'Carlos Eduardo', 'Rio de Janeiro', 'RJ'),
(3, 'Fernanda Lima', 'Belo Horizonte', 'MG'),
(4, 'João Pedro', 'Curitiba', 'PR'),
(5, 'Mariana Alves', 'Porto Alegre', 'RS'),
(6, 'Lucas Rocha', 'Recife', 'PE'),
(7, 'Juliana Costa', 'Fortaleza', 'CE'),
(8, 'Rafael Martins', 'Brasília', 'DF'),
(9, 'Camila Duarte', 'Salvador', 'BA'),
(10, 'Thiago Nunes', 'Manaus', 'AM'),
(11, 'Patrícia Mendes', 'Natal', 'RN'),
(12, 'Bruno Ferreira', 'João Pessoa', 'PB'),
(13, 'Larissa Monteiro', 'Maceió', 'AL'),
(14, 'Diego Santana', 'São Luís', 'MA'),
(15, 'Isabela Ramos', 'Teresina', 'PI'),
(16, 'Gustavo Pires', 'Campo Grande', 'MS'),
(17, 'Aline Barros', 'Cuiabá', 'MT'),
(18, 'Eduarda Silveira', 'Aracaju', 'SE'),
(19, 'Henrique Souza', 'Vitória', 'ES'),
(20, 'Vanessa Oliveira', 'Belém', 'PA');

-- --------------------------------------------------------

--
-- Estrutura para tabela `pedido`
--

CREATE TABLE `pedido` (
  `id_pedido` int(11) NOT NULL,
  `data_emissao` date NOT NULL,
  `id_cliente` int(11) NOT NULL,
  `valor_total` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Despejando dados para a tabela `pedido`
--

INSERT INTO `pedido` (`id_pedido`, `data_emissao`, `id_cliente`, `valor_total`) VALUES
(7, '2025-08-30', 14, 6468.20);

-- --------------------------------------------------------

--
-- Estrutura para tabela `pedido_item`
--

CREATE TABLE `pedido_item` (
  `id_pedido_item` int(11) NOT NULL,
  `id_pedido` int(11) NOT NULL,
  `id_produto` int(11) NOT NULL,
  `quantidade` decimal(10,2) NOT NULL,
  `valor_unitario` decimal(10,2) NOT NULL,
  `valor_total` decimal(10,2) GENERATED ALWAYS AS (`quantidade` * `valor_unitario`) STORED
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Despejando dados para a tabela `pedido_item`
--

INSERT INTO `pedido_item` (`id_pedido_item`, `id_pedido`, `id_produto`, `quantidade`, `valor_unitario`) VALUES
(11, 7, 3, 1.00, 131.50),
(12, 7, 10, 1.00, 3299.00),
(13, 7, 5, 1.00, 799.90),
(14, 7, 19, 1.00, 899.00),
(15, 7, 14, 1.00, 189.90),
(16, 7, 5, 1.00, 799.90),
(17, 7, 9, 1.00, 349.00);

-- --------------------------------------------------------

--
-- Estrutura para tabela `produto`
--

CREATE TABLE `produto` (
  `id_produto` int(11) NOT NULL,
  `descricao` varchar(100) NOT NULL,
  `preco_venda` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Despejando dados para a tabela `produto`
--

INSERT INTO `produto` (`id_produto`, `descricao`, `preco_venda`) VALUES
(1, 'Cafeteira Elétrica 110V', 149.90),
(2, 'Fone de Ouvido Bluetooth', 89.99),
(3, 'Mouse Gamer RGB', 129.50),
(4, 'Teclado Mecânico ABNT2', 249.00),
(5, 'Monitor LED 24\" Full HD', 799.90),
(6, 'Smartphone 128GB Dual Chip', 1899.00),
(7, 'Carregador Turbo USB-C', 59.90),
(8, 'Cadeira Gamer Reclinável', 999.99),
(9, 'HD Externo 1TB', 349.00),
(10, 'Notebook Intel i5 8GB RAM', 3299.00),
(11, 'Impressora Multifuncional Wi-Fi', 499.90),
(12, 'Caixa de Som Portátil', 139.90),
(13, 'Relógio Inteligente Pulseira Silicone', 279.00),
(14, 'Ventilador de Mesa 40cm', 189.90),
(15, 'Liquidificador 5 Velocidades', 159.90),
(16, 'Air Fryer 3,5L', 399.00),
(17, 'Smart TV 50\" 4K', 2499.00),
(18, 'Batedeira Planetária 700W', 349.90),
(19, 'Tablet 10\" 64GB', 899.00),
(20, 'Câmera de Segurança Wi-Fi', 229.90);

--
-- Índices para tabelas despejadas
--

--
-- Índices de tabela `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`id_cliente`);

--
-- Índices de tabela `pedido`
--
ALTER TABLE `pedido`
  ADD PRIMARY KEY (`id_pedido`),
  ADD KEY `pedido_cliente_fk` (`id_cliente`);

--
-- Índices de tabela `pedido_item`
--
ALTER TABLE `pedido_item`
  ADD PRIMARY KEY (`id_pedido_item`),
  ADD KEY `pedidoitem_pedido` (`id_pedido`),
  ADD KEY `pedidoItem_produto` (`id_produto`);

--
-- Índices de tabela `produto`
--
ALTER TABLE `produto`
  ADD PRIMARY KEY (`id_produto`);

--
-- AUTO_INCREMENT para tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `cliente`
--
ALTER TABLE `cliente`
  MODIFY `id_cliente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT de tabela `pedido`
--
ALTER TABLE `pedido`
  MODIFY `id_pedido` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de tabela `pedido_item`
--
ALTER TABLE `pedido_item`
  MODIFY `id_pedido_item` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT de tabela `produto`
--
ALTER TABLE `produto`
  MODIFY `id_produto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- Restrições para tabelas despejadas
--

--
-- Restrições para tabelas `pedido`
--
ALTER TABLE `pedido`
  ADD CONSTRAINT `pedido_cliente_fk` FOREIGN KEY (`id_cliente`) REFERENCES `cliente` (`id_cliente`);

--
-- Restrições para tabelas `pedido_item`
--
ALTER TABLE `pedido_item`
  ADD CONSTRAINT `pedidoItem_produto` FOREIGN KEY (`id_produto`) REFERENCES `produto` (`id_produto`),
  ADD CONSTRAINT `pedidoitem_pedido` FOREIGN KEY (`id_pedido`) REFERENCES `pedido` (`id_pedido`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
