package com.jiwhiz.mydoctor.ws;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.annotation.SendToUser;
import org.springframework.stereotype.Controller;

import org.springframework.ai.chat.client.ChatClient;


@Controller
@RequiredArgsConstructor
@Slf4j
public class MessageController {

    private final ChatClient.Builder chatClientBuilder;

    @MessageMapping("/chat")
    @SendToUser("/queue")
    public MessageDTO chat(@Payload MessageDTO message) {
        log.info("Message received: {}", message);

        var response = chatClientBuilder.build()
                .prompt()
                .user(message.content())
                .functions("portfolioFunction") // reference by bean name.
                .call()
                .content();
        log.info("Message response: {}", response);

        return new MessageDTO(response);
    }

}

