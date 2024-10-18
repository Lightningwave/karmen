-- Create the database
CREATE DATABASE IF NOT EXISTS usedcardealerDB;
USE usedcardealerDB;

-- Create the 'users' table
CREATE TABLE `users` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(255) NOT NULL UNIQUE,
  `password` VARCHAR(255) NOT NULL,
  `role` ENUM('ADMIN', 'AGENT', 'BUYER', 'SELLER') NOT NULL,
  `account_status` ENUM('ACTIVE', 'SUSPENDED') DEFAULT 'ACTIVE',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create the 'user_profiles' table
CREATE TABLE `user_profiles` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `first_name` VARCHAR(255) NOT NULL,
  `last_name` VARCHAR(255) NOT NULL,
  `email` VARCHAR(255) NOT NULL UNIQUE,
  `phone_number` VARCHAR(20),
  `address` VARCHAR(255),
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_profiles_user_id_uindex` (`user_id`),
  CONSTRAINT `fk_user_profiles_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create the 'used_car_listings' table with additional columns
CREATE TABLE `used_car_listings` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `agent_id` BIGINT UNSIGNED NOT NULL,
  `title` VARCHAR(255) NOT NULL,
  `description` TEXT,
  `make` VARCHAR(255) NOT NULL,
  `model` VARCHAR(255) NOT NULL,
  `year` YEAR NOT NULL,
  `price` DECIMAL(15,2) NOT NULL,
  `image` VARCHAR(255),
  `depreciation_per_year` DECIMAL(15,2),
  `registration_date` DATE,
  `mileage` INT UNSIGNED,
  `coe_left` INT UNSIGNED,
  `number_of_owners` INT UNSIGNED,
  `engine_cc` INT UNSIGNED,
  `engine_type` VARCHAR(255),
  `status` ENUM('AVAILABLE', 'SOLD', 'SUSPENDED') DEFAULT 'AVAILABLE',
  `view_count` INT UNSIGNED DEFAULT 0,
  `shortlist_count` INT UNSIGNED DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `used_car_listings_agent_id_index` (`agent_id`),
  CONSTRAINT `fk_used_car_listings_agent_id` FOREIGN KEY (`agent_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create the 'favorite_car_lists' table
CREATE TABLE `favorite_car_lists` (
  `buyer_id` BIGINT UNSIGNED NOT NULL,
  `car_listing_id` BIGINT UNSIGNED NOT NULL,
  `added_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`buyer_id`, `car_listing_id`),
  CONSTRAINT `fk_favorite_car_lists_buyer_id` FOREIGN KEY (`buyer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_favorite_car_lists_car_listing_id` FOREIGN KEY (`car_listing_id`) REFERENCES `used_car_listings` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create the 'reviews' table combining ratings and reviews
CREATE TABLE `reviews` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `author_id` BIGINT UNSIGNED NOT NULL,
  `agent_id` BIGINT UNSIGNED NOT NULL,
  `score` TINYINT UNSIGNED NOT NULL CHECK (`score` BETWEEN 1 AND 5),
  `content` TEXT,
  `timestamp` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_reviews_author_id` FOREIGN KEY (`author_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_reviews_agent_id` FOREIGN KEY (`agent_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- Insert users for each role
INSERT INTO `users` (`username`, `password`, `role`, `account_status`) VALUES
('admin1', 'admin1', 'ADMIN', 'ACTIVE'),     
('agent1', 'agent1', 'AGENT', 'ACTIVE'),      
('buyer1', 'buyer1', 'BUYER', 'ACTIVE'),      
('seller1', 'seller1', 'SELLER', 'ACTIVE');   


-- Insert user profiles corresponding to each user
INSERT INTO `user_profiles` (`user_id`, `first_name`, `last_name`, `email`, `phone_number`, `address`) VALUES
(1, 'Admin', 'User', 'admin1@example.com', '1234567890', '123 Admin St'),
(2, 'John', 'Doe', 'agent1@example.com', '0987654321', '456 Agent Ave'),
(3, 'Anna', 'Smith', 'buyer1@example.com', '5555555555', '789 Buyer Rd'),
(4, 'Mike', 'Brown', 'seller1@example.com', '6666666666', '321 Seller Blvd');

-- Agent (User ID 2) lists two cars
INSERT INTO `used_car_listings` (
  `agent_id`, `title`, `description`, `make`, `model`, `year`, `price`, `image`, `depreciation_per_year`, `registration_date`, `mileage`, `coe_left`, `number_of_owners`, `engine_cc`, `engine_type`, `status`, `view_count`, `shortlist_count`
) VALUES
(2, '2018 Honda Civic', 'Well-maintained, single owner.', 'Honda', 'Civic', 2018, 20000.00, 'images/honda_civic_2018.jpg', 2000.00, '2018-05-15', 30000, 24, 1, 1800, 'Petrol', 'AVAILABLE', 100, 10), 
(2, '2017 Toyota Corolla', 'Low mileage, excellent condition.', 'Toyota', 'Corolla', 2017, 18000.00, 'images/toyota_corolla_2017.jpg', 1800.00, '2017-08-20', 25000, 30, 1, 1600, 'Petrol', 'AVAILABLE', 80, 8);

-- Buyer (User ID 3) favorites both car listings
INSERT INTO `favorite_car_lists` (`buyer_id`, `car_listing_id`, `added_at`) VALUES
(3, 1, CURRENT_TIMESTAMP),  
(3, 2, CURRENT_TIMESTAMP);  

-- Buyer (User ID 3) reviews Agent (User ID 2)
INSERT INTO `reviews` (`author_id`, `agent_id`, `score`, `content`, `timestamp`) VALUES
(3, 2, 5, 'Great experience working with this agent! Highly recommended.', CURRENT_TIMESTAMP);

-- Seller (User ID 4) reviews Agent (User ID 2)
INSERT INTO `reviews` (`author_id`, `agent_id`, `score`, `content`, `timestamp`) VALUES
(4, 2, 4, 'Agent was professional and helped sell my car quickly.', CURRENT_TIMESTAMP);