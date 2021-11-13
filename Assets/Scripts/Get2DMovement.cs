using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Get2DMovement : MonoBehaviour
{
    private Vector2 moveDirection;
    private Vector2 previousPos;
    private Vector2 currPos;

    private void Start()
    {
        this.currPos = this.transform.position;
        this.previousPos = this.transform.position;
    }
    // Update is called once per frame
    void Update()
    {
      
    }

    private void FixedUpdate()
    {
        currPos = this.transform.position;

        moveDirection = (Vector2)(currPos - previousPos).normalized;

        //Debug.Log(Velocity);

        previousPos = currPos;
    }

    public Vector2 MoveDirection() { return this.moveDirection; }
}
